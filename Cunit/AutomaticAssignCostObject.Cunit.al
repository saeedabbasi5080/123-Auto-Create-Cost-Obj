#region CRID 123 - Automatic Create Cost Object Base On Brand For Items
codeunit 50602 AutomaticAssignCostObject
{
    // This event adds the Manufacturer to the TempAllObjWithCaption table
    [EventSubscriber(ObjectType::Codeunit, 408, 'OnAfterDefaultDimObjectNoWithoutGlobalDimsList', '', false, false)]

    local procedure OnAfterDefaultDimObjectNoWithoutGlobalDimsList(var TempAllObjWithCaption: Record AllObjWithCaption temporary)
    var
        DimensionManagement: Codeunit "DimensionManagement";
    begin
        DimensionManagement.DefaultDimInsertTempObject(TempAllObjWithCaption, Database::"Manufacturer");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertDefaultDimension(var Rec: Record "Default Dimension"; RunTrigger: Boolean)
    begin
        InsertItemDefaultDimFromManufacturer(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterDeleteDefaultDimension(var Rec: Record "Default Dimension"; RunTrigger: Boolean)
    begin
        DeleteItemDefaultDimFromManufacturer(Rec);
    end;


    // EventSubscriber: Update Item Default Dimension when any dimension of Manufacturer changes
    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyDefaultDimension(var Rec: Record "Default Dimension"; xRec: Record "Default Dimension"; RunTrigger: Boolean)
    begin
        UpdateItemDefaultDimFromManufacturer(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterValidateEvent', 'Manufacturer Code', false, false)]
    local procedure OnAfterValidateItem(var Rec: Record Item; xRec: Record Item)
    begin
        SyncItemCostObjectDefaultDimWithManufacturer(Rec, xRec);
    end;

    local procedure InsertItemDefaultDimFromManufacturer(Rec: Record "Default Dimension")
    var
        ItemRec: Record Item;
        DefaultDim: Record "Default Dimension";
        Manufacturer: Record Manufacturer;
        InventorySetup: Record "Inventory Setup";
        CostObjectDimCode: Code[20];
    begin
        if not IsAutoAssignCostObjectEnabled then
            exit;

        if Rec."Table ID" = Database::Item then
            exit;

        CostObjectDimCode := 'COST OBJECT';

        if (Rec."Table ID" = Database::Manufacturer) and (Rec."Dimension Code" = CostObjectDimCode) and Manufacturer.Get(Rec."No.") then begin
            ItemRec.Reset();
            ItemRec.SetRange("Manufacturer Code", Rec."No.");
            if ItemRec.FindSet() then
                repeat
                    DefaultDim.Reset();
                    DefaultDim.SetRange("Table ID", Database::Item);
                    DefaultDim.SetRange("No.", ItemRec."No.");
                    DefaultDim.SetRange("Dimension Code", CostObjectDimCode);
                    if not DefaultDim.FindFirst() then begin
                        DefaultDim.Init();
                        DefaultDim."Table ID" := Database::Item;
                        DefaultDim."No." := ItemRec."No.";
                        DefaultDim."Dimension Code" := Rec."Dimension Code";
                        DefaultDim."Dimension Value Code" := Rec."Dimension Value Code";
                        DefaultDim."Value Posting" := Rec."Value Posting";
                        DefaultDim."Allowed Values Filter" := Rec."Allowed Values Filter";
                        DefaultDim.Insert();
                    end;
                until ItemRec.Next() = 0;
        end;
    end;

    local procedure DeleteItemDefaultDimFromManufacturer(Rec: Record "Default Dimension")
    var
        ItemRec: Record Item;
        DefaultDim: Record "Default Dimension";
        InventorySetup: Record "Inventory Setup";
        CostObjectDimCode: Code[20];
    begin
        if not IsAutoAssignCostObjectEnabled then
            exit;

        CostObjectDimCode := 'COST OBJECT';

        if Rec."Table ID" = Database::Manufacturer then begin
            if Rec."Dimension Code" = CostObjectDimCode then begin
                ItemRec.Reset();
                ItemRec.SetRange("Manufacturer Code", Rec."No.");
                if ItemRec.FindSet() then
                    repeat
                        DefaultDim.Reset();
                        DefaultDim.SetRange("Table ID", Database::Item);
                        DefaultDim.SetRange("No.", ItemRec."No.");
                        DefaultDim.SetRange("Dimension Code", CostObjectDimCode);
                        if DefaultDim.FindFirst() then
                            DefaultDim.Delete();
                    until ItemRec.Next() = 0;
            end;
        end;
    end;

    local procedure UpdateItemDefaultDimFromManufacturer(Rec: Record "Default Dimension")
    var
        ItemRec: Record Item;
        DefaultDim: Record "Default Dimension";
        Manufacturer: Record Manufacturer;
        InventorySetup: Record "Inventory Setup";
        CostObjectDimCode: Code[20];
    begin
        if not IsAutoAssignCostObjectEnabled then
            exit;

        if Rec."Table ID" = Database::Item then
            exit; // Only handle Manufacturer dimensions    

        CostObjectDimCode := 'COST OBJECT';

        // Only if this record is related to the Manufacturer and the Manufacturer Code is valid
        if (Rec."Table ID" = Database::Manufacturer) and Manufacturer.Get(Rec."No.") then begin
            if Rec."Dimension Code" = CostObjectDimCode then begin
                ItemRec.Reset();
                ItemRec.SetRange("Manufacturer Code", Rec."No.");
                if ItemRec.FindSet() then
                    repeat
                        DefaultDim.Reset();
                        DefaultDim.SetRange("Table ID", Database::Item);
                        DefaultDim.SetRange("No.", ItemRec."No.");
                        DefaultDim.SetRange("Dimension Code", CostObjectDimCode);
                        if DefaultDim.FindFirst() then begin
                            DefaultDim."Dimension Value Code" := Rec."Dimension Value Code";
                            DefaultDim."Value Posting" := Rec."Value Posting";
                            DefaultDim."Allowed Values Filter" := Rec."Allowed Values Filter";
                            DefaultDim.Modify();
                        end else begin
                            DefaultDim.Init();
                            DefaultDim."Table ID" := Database::Item;
                            DefaultDim."No." := ItemRec."No.";
                            DefaultDim."Dimension Code" := Rec."Dimension Code";
                            DefaultDim."Dimension Value Code" := Rec."Dimension Value Code";
                            DefaultDim."Value Posting" := Rec."Value Posting";
                            DefaultDim."Allowed Values Filter" := Rec."Allowed Values Filter";
                            DefaultDim.Insert();
                        end;
                    until ItemRec.Next() = 0;
            end;
        end;
    end;

    local procedure SyncItemCostObjectDefaultDimWithManufacturer(var ItemRec: Record Item; xItemRec: Record Item)
    var
        DefaultDim: Record "Default Dimension";
        ManufacturerDim: Record "Default Dimension";
        InventorySetup: Record "Inventory Setup";
        ManufacturerTableID: Integer;
        CostObjectDimCode: Code[20];
    begin
        if not IsAutoAssignCostObjectEnabled then
            exit;
        ManufacturerTableID := Database::Manufacturer;
        CostObjectDimCode := 'COST OBJECT';

        // Only if the Manufacturer Code has changed
        if ItemRec."Manufacturer Code" <> xItemRec."Manufacturer Code" then begin
            // Delete only COST OBJECT Default Dimensions for the item
            DefaultDim.Reset();
            DefaultDim.SetRange("Table ID", Database::Item);
            DefaultDim.SetRange("No.", ItemRec."No.");
            DefaultDim.SetRange("Dimension Code", CostObjectDimCode);
            if DefaultDim.FindSet() then
                repeat
                    DefaultDim.Delete();
                until DefaultDim.Next() = 0;

            // Add new COST OBJECT dimension from Manufacturer if exists
            if ItemRec."Manufacturer Code" <> '' then begin
                ManufacturerDim.Reset();
                ManufacturerDim.SetRange("Table ID", ManufacturerTableID);
                ManufacturerDim.SetRange("No.", ItemRec."Manufacturer Code");
                ManufacturerDim.SetRange("Dimension Code", CostObjectDimCode);
                if ManufacturerDim.FindFirst() then begin
                    DefaultDim.Init();
                    DefaultDim."Table ID" := Database::Item;
                    DefaultDim."No." := ItemRec."No.";
                    DefaultDim."Dimension Code" := ManufacturerDim."Dimension Code";
                    DefaultDim."Dimension Value Code" := ManufacturerDim."Dimension Value Code";
                    DefaultDim."Value Posting" := ManufacturerDim."Value Posting";
                    DefaultDim."Allowed Values Filter" := ManufacturerDim."Allowed Values Filter";
                    DefaultDim.Insert();
                end;
            end;
        end;
    end;

    local procedure IsAutoAssignCostObjectEnabled(): Boolean
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        exit(InventorySetup."Automatic Assign Cost Object");
    end;
}
#endregion 123 - Automatic Create Cost Object Base On Brand For Items