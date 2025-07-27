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


    // EventSubscriber new:
    // In all code, only the Manufacturer dimension should be read from the Item record:
    // (In OnAfterModifyItem and UpdateAllItemsWithSameManufacturer and ...)

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyItem(var Rec: Record Item; xRec: Record Item; RunTrigger: Boolean)
    var
        DefaultDim: Record "Default Dimension";
        ManufacturerDim: Record "Default Dimension";
        InventorySetup: Record "Inventory Setup";
        ManufacturerTableID: Integer;
    begin
        InventorySetup.Get();
        if not InventorySetup."Automatic Assign Cost Object" then
            exit;
        ManufacturerTableID := Database::Manufacturer;

        // Only if the Manufacturer Code has changed
        if Rec."Manufacturer Code" <> xRec."Manufacturer Code" then begin
            // Delete all existing Default Dimensions for the item
            DefaultDim.Reset();
            DefaultDim.SetRange("Table ID", Database::Item);
            DefaultDim.SetRange("No.", Rec."No.");
            if DefaultDim.FindSet() then
                repeat
                    DefaultDim.Delete();
                until DefaultDim.Next() = 0;

            // Add new Manufacturer dimensions (always from the Manufacturer record)
            if Rec."Manufacturer Code" <> '' then begin
                ManufacturerDim.Reset();
                ManufacturerDim.SetRange("Table ID", ManufacturerTableID);
                ManufacturerDim.SetRange("No.", Rec."Manufacturer Code");
                if ManufacturerDim.FindSet() then
                    repeat
                        DefaultDim.Init();
                        DefaultDim."Table ID" := Database::Item;
                        DefaultDim."No." := Rec."No.";
                        DefaultDim."Dimension Code" := ManufacturerDim."Dimension Code";
                        DefaultDim."Dimension Value Code" := ManufacturerDim."Dimension Value Code";
                        DefaultDim."Value Posting" := ManufacturerDim."Value Posting";
                        DefaultDim."Allowed Values Filter" := ManufacturerDim."Allowed Values Filter";
                        DefaultDim.Insert();
                    until ManufacturerDim.Next() = 0;
            end;

            // Prevent infinite loop
            if not IsUpdatingAllItems then begin
                IsUpdatingAllItems := true;
                UpdateAllItemsWithSameManufacturer(Rec."Manufacturer Code", xRec."Manufacturer Code");
                IsUpdatingAllItems := false;
            end;
        end;
    end;



    // EventSubscriber: Update Item Default Dimension when any field of Manufacturer changes
    [EventSubscriber(ObjectType::Table, Database::Manufacturer, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyManufacturer(var Rec: Record Manufacturer; xRec: Record Manufacturer; RunTrigger: Boolean)
    var
        ItemRec: Record Item;
        ManufacturerDim: Record "Default Dimension";
        DefaultDim: Record "Default Dimension";
    begin
        // Find all items that have the same Manufacturer Code
        ItemRec.Reset();
        ItemRec.SetRange("Manufacturer Code", Rec."Code");
        if ItemRec.FindSet() then
            repeat
                // Delete existing Default Dimensions for the item (to prevent conflicts)
                DefaultDim.Reset();
                DefaultDim.SetRange("Table ID", Database::Item);
                DefaultDim.SetRange("No.", ItemRec."No.");
                if DefaultDim.FindSet() then
                    repeat
                        DefaultDim.Delete();
                    until DefaultDim.Next() = 0;

                // Add new dimensions related to the Manufacturer
                ManufacturerDim.Reset();
                ManufacturerDim.SetRange("Table ID", Database::Manufacturer);
                ManufacturerDim.SetRange("No.", Rec."Code");
                if ManufacturerDim.FindSet() then
                    repeat
                        DefaultDim.Init();
                        DefaultDim."Table ID" := Database::Item;
                        DefaultDim."No." := ItemRec."No.";
                        DefaultDim."Dimension Code" := ManufacturerDim."Dimension Code";
                        DefaultDim."Dimension Value Code" := ManufacturerDim."Dimension Value Code";
                        DefaultDim."Value Posting" := ManufacturerDim."Value Posting";
                        DefaultDim."Allowed Values Filter" := ManufacturerDim."Allowed Values Filter";
                        DefaultDim.Insert();
                    until ManufacturerDim.Next() = 0;
            until ItemRec.Next() = 0;
    end;

    // [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterInsertEvent', '', false, false)]
    // local procedure OnAfterInsertDefaultDimension(var Rec: Record "Default Dimension"; RunTrigger: Boolean)
    // begin
    //     Message('OnAfterInsertDefaultDimension');
    //     UpdateItemDimensionsFromManufacturer(Rec."No.");

    // end;

    // [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAftervalidateEvent', 'Dimension Code', false, false)]
    // local procedure OnAfterValidateDefaultDimension(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension")
    // var
    //     ItemRec: Record Item;
    //     DefaultDim: Record "Default Dimension";
    //     ManufacturerDim: Record "Default Dimension";
    //     InventorySetup: Record "Inventory Setup";
    // begin
    //     InventorySetup.Get();
    //     if not InventorySetup."Automatic Assign Cost Object" then
    //         exit;

    //     // Only if this dimension is related to Manufacturer
    //     if Rec."Table ID" = Database::Manufacturer then begin
    //         // Find items that have this Manufacturer
    //         ItemRec.Reset();
    //         ItemRec.SetRange("Manufacturer Code", Rec."No.");
    //         if ItemRec.FindSet() then
    //             repeat
    //                 // Delete all item dimensions
    //                 DefaultDim.Reset();
    //                 DefaultDim.SetRange("Table ID", Database::Item);
    //                 DefaultDim.SetRange("No.", ItemRec."No.");
    //                 if DefaultDim.FindSet() then
    //                     repeat
    //                         DefaultDim.Delete();
    //                     until DefaultDim.Next() = 0;

    //                 // Add remaining dimensions from Manufacturer
    //                 ManufacturerDim.Reset();
    //                 ManufacturerDim.SetRange("Table ID", Database::Manufacturer);
    //                 ManufacturerDim.SetRange("No.", Rec."No.");
    //                 if ManufacturerDim.FindSet() then
    //                     repeat
    //                         DefaultDim.Init();
    //                         DefaultDim."Table ID" := Database::Item;
    //                         DefaultDim."No." := ItemRec."No.";
    //                         DefaultDim."Dimension Code" := ManufacturerDim."Dimension Code";
    //                         DefaultDim."Dimension Value Code" := ManufacturerDim."Dimension Value Code";
    //                         DefaultDim."Value Posting" := ManufacturerDim."Value Posting";
    //                         DefaultDim."Allowed Values Filter" := ManufacturerDim."Allowed Values Filter";
    //                         DefaultDim.Insert();
    //                     until ManufacturerDim.Next() = 0;
    //             until ItemRec.Next() = 0;
    //     end;
    // end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterDeleteDefaultDimension(var Rec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        ItemRec: Record Item;
        DefaultDim: Record "Default Dimension";
        ManufacturerDim: Record "Default Dimension";
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        if not InventorySetup."Automatic Assign Cost Object" then
            exit;

        // Only if this dimension is related to Manufacturer
        if Rec."Table ID" = Database::Manufacturer then begin
            // Find items that have this Manufacturer
            ItemRec.Reset();
            ItemRec.SetRange("Manufacturer Code", Rec."No.");
            if ItemRec.FindSet() then
                repeat
                    // Delete all item dimensions
                    DefaultDim.Reset();
                    DefaultDim.SetRange("Table ID", Database::Item);
                    DefaultDim.SetRange("No.", ItemRec."No.");
                    if DefaultDim.FindSet() then
                        repeat
                            DefaultDim.Delete();
                        until DefaultDim.Next() = 0;

                    // Add remaining dimensions from Manufacturer
                    ManufacturerDim.Reset();
                    ManufacturerDim.SetRange("Table ID", Database::Manufacturer);
                    ManufacturerDim.SetRange("No.", Rec."No.");
                    if ManufacturerDim.FindSet() then
                        repeat
                            DefaultDim.Init();
                            DefaultDim."Table ID" := Database::Item;
                            DefaultDim."No." := ItemRec."No.";
                            DefaultDim."Dimension Code" := ManufacturerDim."Dimension Code";
                            DefaultDim."Dimension Value Code" := ManufacturerDim."Dimension Value Code";
                            DefaultDim."Value Posting" := ManufacturerDim."Value Posting";
                            DefaultDim."Allowed Values Filter" := ManufacturerDim."Allowed Values Filter";
                            DefaultDim.Insert();
                        until ManufacturerDim.Next() = 0;
                until ItemRec.Next() = 0;
        end;
    end;

    // [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterModifyEvent', '', false, false)]
    // local procedure OnAfterModifyDefaultDimension(var Rec: Record "Default Dimension"; xRec: Record "Default Dimension"; RunTrigger: Boolean)
    // begin
    //     // Only if this record is related to Manufacturer
    //     if Rec."Table ID" = Database::Manufacturer then
    //         UpdateItemDimensionsFromManufacturer(Rec."No.");
    // end;

    // EventSubscriber: Update Item Default Dimension when any dimension of Manufacturer changes
    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyDefaultDimension(var Rec: Record "Default Dimension"; xRec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        ItemRec: Record Item;
        DefaultDim: Record "Default Dimension";
        ManufacturerDim: Record "Default Dimension";
        Manufacturer: Record Manufacturer;
        InventorySetup: Record "Inventory Setup";
    begin
        // Message('OnAfterDeleteDefaultDimension');
        InventorySetup.Get();
        if not InventorySetup."Automatic Assign Cost Object" then
            exit;

        // Only if this record is related to the Manufacturer and the Manufacturer Code is valid
        if (Rec."Table ID" = Database::Manufacturer) and Manufacturer.Get(Rec."No.") then begin
            // Find all items that have the same Manufacturer Code
            ItemRec.Reset();
            ItemRec.SetRange("Manufacturer Code", Rec."No.");
            if ItemRec.FindSet() then
                repeat
                    // Delete all Default Dimensions for the item
                    DefaultDim.Reset();
                    DefaultDim.SetRange("Table ID", Database::Item);
                    DefaultDim.SetRange("No.", ItemRec."No.");
                    if DefaultDim.FindSet() then
                        repeat
                            DefaultDim.Delete();
                        until DefaultDim.Next() = 0;

                    // For this item, insert ALL Default Dimensions of the Manufacturer (not just the changed one)
                    ManufacturerDim.Reset();
                    ManufacturerDim.SetRange("Table ID", Database::Manufacturer);
                    ManufacturerDim.SetRange("No.", Rec."No.");
                    if ManufacturerDim.FindSet() then
                        repeat
                            DefaultDim.Init();
                            DefaultDim."Table ID" := Database::Item;
                            DefaultDim."No." := ItemRec."No.";
                            DefaultDim."Dimension Code" := ManufacturerDim."Dimension Code";
                            DefaultDim."Dimension Value Code" := ManufacturerDim."Dimension Value Code";
                            DefaultDim."Value Posting" := ManufacturerDim."Value Posting";
                            DefaultDim."Allowed Values Filter" := ManufacturerDim."Allowed Values Filter";
                            DefaultDim.Insert();
                        until ManufacturerDim.Next() = 0;
                until ItemRec.Next() = 0;
        end;
    end;

    // Return procedure UpdateAllItemsWithSameManufacturer

    local procedure UpdateAllItemsWithSameManufacturer(NewManufacturerCode: Code[20]; OldManufacturerCode: Code[20])
    var
        ItemRec: Record Item;
        DefaultDim: Record "Default Dimension";
        ManufacturerDim: Record "Default Dimension";
        InventorySetup: Record "Inventory Setup";
        ManufacturerTableID: Integer;
    begin
        InventorySetup.Get();
        if not InventorySetup."Automatic Assign Cost Object" then
            exit;
        ManufacturerTableID := Database::Manufacturer;

        // Update items that had the old Manufacturer Code
        if OldManufacturerCode <> '' then begin
            ItemRec.Reset();
            ItemRec.SetRange("Manufacturer Code", OldManufacturerCode);
            if ItemRec.FindSet() then
                repeat
                    // Delete existing Default Dimensions for the item
                    DefaultDim.Reset();
                    DefaultDim.SetRange("Table ID", Database::Item);
                    DefaultDim.SetRange("No.", ItemRec."No.");
                    if DefaultDim.FindSet() then
                        repeat
                            DefaultDim.Delete();
                        until DefaultDim.Next() = 0;
                until ItemRec.Next() = 0;
            // Re-insert Default Dimensions for items that still have the old Manufacturer Code
            ItemRec.Reset();
            ItemRec.SetRange("Manufacturer Code", OldManufacturerCode);
            if ItemRec.FindSet() then
                repeat
                    ManufacturerDim.Reset();
                    ManufacturerDim.SetRange("Table ID", ManufacturerTableID);
                    ManufacturerDim.SetRange("No.", OldManufacturerCode);
                    if ManufacturerDim.FindSet() then
                        repeat
                            DefaultDim.Init();
                            DefaultDim."Table ID" := Database::Item;
                            DefaultDim."No." := ItemRec."No.";
                            DefaultDim."Dimension Code" := ManufacturerDim."Dimension Code";
                            DefaultDim."Dimension Value Code" := ManufacturerDim."Dimension Value Code";
                            DefaultDim."Value Posting" := ManufacturerDim."Value Posting";
                            DefaultDim."Allowed Values Filter" := ManufacturerDim."Allowed Values Filter";
                            DefaultDim.Insert();
                        until ManufacturerDim.Next() = 0;
                until ItemRec.Next() = 0;
        end;

        // Update items that have the new Manufacturer Code
        if NewManufacturerCode <> '' then begin
            ItemRec.Reset();
            ItemRec.SetRange("Manufacturer Code", NewManufacturerCode);
            if ItemRec.FindSet() then
                repeat
                    // Delete existing Default Dimensions for the item
                    DefaultDim.Reset();
                    DefaultDim.SetRange("Table ID", Database::Item);
                    DefaultDim.SetRange("No.", ItemRec."No.");
                    if DefaultDim.FindSet() then
                        repeat
                            DefaultDim.Delete();
                        until DefaultDim.Next() = 0;

                    // Add new Manufacturer Default Dimensions (always from the Manufacturer record)
                    ManufacturerDim.Reset();
                    ManufacturerDim.SetRange("Table ID", ManufacturerTableID);
                    ManufacturerDim.SetRange("No.", NewManufacturerCode);
                    if ManufacturerDim.FindSet() then
                        repeat
                            DefaultDim.Init();
                            DefaultDim."Table ID" := Database::Item;
                            DefaultDim."No." := ItemRec."No.";
                            DefaultDim."Dimension Code" := ManufacturerDim."Dimension Code";
                            DefaultDim."Dimension Value Code" := ManufacturerDim."Dimension Value Code";
                            DefaultDim."Value Posting" := ManufacturerDim."Value Posting";
                            DefaultDim."Allowed Values Filter" := ManufacturerDim."Allowed Values Filter";
                            DefaultDim.Insert();
                        until ManufacturerDim.Next() = 0;
                until ItemRec.Next() = 0;
        end;
    end;


    // Local procedure for updating Item Default Dimensions based on Manufacturer
    // local procedure UpdateItemDimensionsFromManufacturer(ManufacturerCode: Code[20])
    // var
    //     ItemRec: Record Item;
    //     DefaultDim: Record "Default Dimension";
    //     ManufacturerDim: Record "Default Dimension";
    //     Manufacturer: Record Manufacturer;
    //     InventorySetup: Record "Inventory Setup";
    // begin
    //     InventorySetup.Get();
    //     if not InventorySetup."Automatic Assign Cost Object" then
    //         exit;

    //     // Check if the record is related to Manufacturer and Manufacturer Code is valid
    //     // if not Manufacturer.Get(ManufacturerCode) then
    //     //     exit;

    //     // Find all items that have the same Manufacturer Code
    //     ItemRec.Reset();
    //     ItemRec.SetRange("Manufacturer Code", ManufacturerCode);
    //     if ItemRec.FindSet() then
    //         repeat
    //             // Delete all existing Default Dimensions for the item
    //             DefaultDim.Reset();
    //             DefaultDim.SetRange("Table ID", Database::Item);
    //             DefaultDim.SetRange("No.", ItemRec."No.");
    //             if DefaultDim.FindSet() then
    //                 repeat
    //                     DefaultDim.Delete();
    //                 until DefaultDim.Next() = 0;

    //             // For this item, insert ALL Default Dimensions from Manufacturer (not just the changed one)
    //             ManufacturerDim.Reset();
    //             ManufacturerDim.SetRange("Table ID", Database::Manufacturer);
    //             ManufacturerDim.SetRange("No.", ManufacturerCode);
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

}
#endregion 123 - Automatic Create Cost Object Base On Brand For Items