#region 123 - Automatic Create Cost Object Base On Brand For Items
codeunit 50602 DimInsertTempObjectCunit
{
    var
        IsUpdatingAllItems: Boolean;
    // This event adds the Manufacturer to the TempAllObjWithCaption table
    [EventSubscriber(ObjectType::Codeunit, 408, 'OnAfterDefaultDimObjectNoWithoutGlobalDimsList', '', false, false)]

    local procedure OnAfterDefaultDimObjectNoWithoutGlobalDimsList(var TempAllObjWithCaption: Record AllObjWithCaption temporary)
    var
        DimensionManagement: Codeunit "DimensionManagement";
    begin
        DimensionManagement.DefaultDimInsertTempObject(TempAllObjWithCaption, Database::"Manufacturer");
    end;


    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterValidateEvent', 'Manufacturer Code', false, false)]
    local procedure OnAfterModifyItem(var Rec: Record Item; xRec: Record Item)
    var
        DefaultDim: Record "Default Dimension";
        ManufacturerDim: Record "Default Dimension";
        InventorySetup: Record "Inventory Setup";
        ManufacturerTableID: Integer;
        CostObjectDimCode: Code[20];
    begin
        InventorySetup.Get();
        if not InventorySetup."Automatic Assign Cost Object" then
            exit;

        ManufacturerTableID := Database::Manufacturer;
        CostObjectDimCode := 'COST OBJECT';

        // Only if the Manufacturer Code has changed
        if Rec."Manufacturer Code" <> xRec."Manufacturer Code" then begin

            if Rec."Manufacturer Code" <> '' then begin
                // بررسی اینکه آیا Manufacturer جدید COST OBJECT dimension دارد یا نه
                ManufacturerDim.Reset();
                ManufacturerDim.SetRange("Table ID", ManufacturerTableID);
                ManufacturerDim.SetRange("No.", Rec."Manufacturer Code");
                ManufacturerDim.SetRange("Dimension Code", CostObjectDimCode);

                if ManufacturerDim.FindFirst() then begin
                    // اگر دارد -> آپدیت کن
                    DefaultDim.Reset();
                    DefaultDim.SetRange("Table ID", Database::Item);
                    DefaultDim.SetRange("No.", Rec."No.");
                    DefaultDim.SetRange("Dimension Code", CostObjectDimCode);

                    if DefaultDim.FindFirst() then begin
                        DefaultDim."Dimension Value Code" := ManufacturerDim."Dimension Value Code";
                        DefaultDim."Value Posting" := ManufacturerDim."Value Posting";
                        DefaultDim."Allowed Values Filter" := ManufacturerDim."Allowed Values Filter";
                        DefaultDim.Modify();
                    end else begin
                        DefaultDim.Init();
                        DefaultDim."Table ID" := Database::Item;
                        DefaultDim."No." := Rec."No.";
                        DefaultDim."Dimension Code" := CostObjectDimCode;
                        DefaultDim."Dimension Value Code" := ManufacturerDim."Dimension Value Code";
                        DefaultDim."Value Posting" := ManufacturerDim."Value Posting";
                        DefaultDim."Allowed Values Filter" := ManufacturerDim."Allowed Values Filter";
                        DefaultDim.Insert();
                    end;
                end else begin
                    // اگر ندارد -> حذف کن از Item
                    DefaultDim.Reset();
                    DefaultDim.SetRange("Table ID", Database::Item);
                    DefaultDim.SetRange("No.", Rec."No.");
                    DefaultDim.SetRange("Dimension Code", CostObjectDimCode);
                    if DefaultDim.FindFirst() then
                        DefaultDim.Delete();
                end;
            end else begin
                // اگر Manufacturer Code خالی شد -> حذف کن
                DefaultDim.Reset();
                DefaultDim.SetRange("Table ID", Database::Item);
                DefaultDim.SetRange("No.", Rec."No.");
                DefaultDim.SetRange("Dimension Code", CostObjectDimCode);
                if DefaultDim.FindFirst() then
                    DefaultDim.Delete();
            end;
        end;
    end;

    // EventSubscriber: Update Item Default Dimension when any field of Manufacturer changes
    // [EventSubscriber(ObjectType::Table, Database::Manufacturer, 'OnAfterModifyEvent', '', false, false)]
    // local procedure OnAfterModifyManufacturer(var Rec: Record Manufacturer; xRec: Record Manufacturer; RunTrigger: Boolean)
    // var
    //     ItemRec: Record Item;
    //     ManufacturerDim: Record "Default Dimension";
    //     DefaultDim: Record "Default Dimension";
    // begin
    //     // Find all items that have the same Manufacturer Code
    //     ItemRec.Reset();
    //     ItemRec.SetRange("Manufacturer Code", Rec."Code");
    //     if ItemRec.FindSet() then
    //         repeat
    //             // Delete existing Default Dimensions for the item (to prevent conflicts)
    //             DefaultDim.Reset();
    //             DefaultDim.SetRange("Table ID", Database::Item);
    //             DefaultDim.SetRange("No.", ItemRec."No.");
    //             if DefaultDim.FindSet() then
    //                 repeat
    //                     DefaultDim.Delete();
    //                 until DefaultDim.Next() = 0;

    //             // Add new dimensions related to the Manufacturer
    //             ManufacturerDim.Reset();
    //             ManufacturerDim.SetRange("Table ID", Database::Manufacturer);
    //             ManufacturerDim.SetRange("No.", Rec."Code");
    //             if ManufacturerDim.FindSet() then
    //                 repeat
    //                     DefaultDim.Init();
    //                     DefaultDim."Table ID" := Database::Item;
    //                     DefaultDim."No." := ItemRec."No.";
    //                     DefaultDim."Dimension Code" := ManufacturerDim."Dimension Code";
    //                     DefaultDim."Dimension Value Code" := ManufacturerDim."Dimension Value Code";
    //                     DefaultDim."Value Posting" := ManufacturerDim."Value Posting";
    //                     DefaultDim."Allowed Values Filter" := ManufacturerDim."Allowed Values Filter";
    //                     DefaultDim.Insert();
    //                 until ManufacturerDim.Next() = 0;
    //         until ItemRec.Next() = 0;
    // end;


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

        // فقط اگر این dimension مربوط به Manufacturer باشد
        if Rec."Table ID" = Database::Manufacturer then begin
            // اگر dimension حذف شده 'COST OBJECT' باشد
            if Rec."Dimension Code" = CostObjectDimCode then begin
                // فقط همین dimension را از آیتم‌ها حذف کن
                ItemRec.Reset();
                ItemRec.SetRange("Manufacturer Code", Rec."No.");
                if ItemRec.FindSet() then
                    repeat
                        // پیدا کردن و حذف کردن فقط COST OBJECT dimension
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
            // اگر dimension تغییر یافته 'COST OBJECT' باشد
            if Rec."Dimension Code" = CostObjectDimCode then begin
                // فقط همین dimension را در آیتم‌ها آپدیت کن
                ItemRec.Reset();
                ItemRec.SetRange("Manufacturer Code", Rec."No.");
                if ItemRec.FindSet() then
                    repeat
                        // پیدا کردن و آپدیت کردن فقط COST OBJECT dimension
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
                            // اگر وجود نداشت، اضافه کن
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