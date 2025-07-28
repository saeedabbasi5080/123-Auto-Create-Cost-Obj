#region 123 - Automatic Create Cost Object Base On Brand For Items
codeunit 50602 DimInsertTempObjectCunit
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
    var
        ItemRec: Record Item;
        DefaultDim: Record "Default Dimension";
        Manufacturer: Record Manufacturer;
        InventorySetup: Record "Inventory Setup";
        CostObjectDimCode: Code[20];
    begin
        InventorySetup.Get();
        if not InventorySetup."Automatic Assign Cost Object" then
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

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterDeleteDefaultDimension(var Rec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        ItemRec: Record Item;
        DefaultDim: Record "Default Dimension";
        ManufacturerDim: Record "Default Dimension";
        InventorySetup: Record "Inventory Setup";
        CostObjectDimCode: Code[20];
    begin
        InventorySetup.Get();
        if not InventorySetup."Automatic Assign Cost Object" then
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


    // EventSubscriber: Update Item Default Dimension when any dimension of Manufacturer changes
    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyDefaultDimension(var Rec: Record "Default Dimension"; xRec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        ItemRec: Record Item;
        DefaultDim: Record "Default Dimension";
        ManufacturerDim: Record "Default Dimension";
        Manufacturer: Record Manufacturer;
        InventorySetup: Record "Inventory Setup";
        CostObjectDimCode: Code[20];
    begin
        InventorySetup.Get();
        if not InventorySetup."Automatic Assign Cost Object" then
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
}
#endregion 123 - Automatic Create Cost Object Base On Brand For Items