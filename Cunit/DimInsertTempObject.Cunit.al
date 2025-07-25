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


    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterValidateEvent', 'Manufacturer Code', false, false)]
    local procedure OnAfterValidateManufacturerCode(var Rec: Record Item; xRec: Record Item)
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

        // حذف همه Default Dimensionهای آیتم که مربوط به Manufacturer قبلی بودند
        DefaultDim.Reset();
        DefaultDim.SetRange("Table ID", Database::Item);
        DefaultDim.SetRange("No.", Rec."No.");
        DefaultDim.SetRange("Dimension Code");
        if DefaultDim.FindSet() then
            repeat
                // فقط دایمنشن‌هایی که در Manufacturer قبلی وجود داشتند حذف شوند
                if xRec."Manufacturer Code" <> '' then begin
                    ManufacturerDim.Reset();
                    ManufacturerDim.SetRange("Table ID", ManufacturerTableID);
                    ManufacturerDim.SetRange("No.", xRec."Manufacturer Code");
                    ManufacturerDim.SetRange("Dimension Code", DefaultDim."Dimension Code");
                    if ManufacturerDim.FindFirst() then
                        DefaultDim.Delete();
                end;
            until DefaultDim.Next() = 0;

        // اضافه کردن دایمنشن‌های Manufacturer جدید
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
    end;

    // EventSubscriber: Update Item Default Dimension when any field of Manufacturer changes
    [EventSubscriber(ObjectType::Table, Database::Manufacturer, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyManufacturer(var Rec: Record Manufacturer; xRec: Record Manufacturer; RunTrigger: Boolean)
    var
        ItemRec: Record Item;
        ManufacturerDim: Record "Default Dimension";
        DefaultDim: Record "Default Dimension";
        CostObjectDimCode: Code[20];
    begin
        // فرض: Dimension Code مورد نظر 'COST OBJECT' است
        CostObjectDimCode := 'COST OBJECT';
        // پیدا کردن همه آیتم‌هایی که Manufacturer Code آن‌ها برابر با این Manufacturer است
        ItemRec.Reset();
        ItemRec.SetRange("Manufacturer Code", Rec."Code");
        if ItemRec.FindSet() then
            repeat
                // پیدا کردن Dimension مربوط به Manufacturer و Dimension Code مورد نظر
                ManufacturerDim.Reset();
                ManufacturerDim.SetRange("Table ID", Database::Manufacturer);
                ManufacturerDim.SetRange("No.", Rec."Code");
                ManufacturerDim.SetRange("Dimension Code", CostObjectDimCode);
                if ManufacturerDim.FindFirst() then begin
                    // به‌روزرسانی یا درج Dimension روی آیتم
                    DefaultDim.Reset();
                    DefaultDim.SetRange("Table ID", Database::Item);
                    DefaultDim.SetRange("No.", ItemRec."No.");
                    DefaultDim.SetRange("Dimension Code", CostObjectDimCode);
                    if DefaultDim.FindFirst() then begin
                        DefaultDim."Dimension Value Code" := ManufacturerDim."Dimension Value Code";
                        DefaultDim."Value Posting" := ManufacturerDim."Value Posting";
                        DefaultDim."Allowed Values Filter" := ManufacturerDim."Allowed Values Filter";
                        DefaultDim.Modify();
                    end else begin
                        DefaultDim.Init();
                        DefaultDim."Table ID" := Database::Item;
                        DefaultDim."No." := ItemRec."No.";
                        DefaultDim."Dimension Code" := CostObjectDimCode;
                        DefaultDim."Dimension Value Code" := ManufacturerDim."Dimension Value Code";
                        DefaultDim."Value Posting" := ManufacturerDim."Value Posting";
                        DefaultDim."Allowed Values Filter" := ManufacturerDim."Allowed Values Filter";
                        DefaultDim.Insert();
                    end;
                end;
            until ItemRec.Next() = 0;
    end;

    // EventSubscriber: Update Item Default Dimension when any dimension of Manufacturer changes
    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyDefaultDimension(var Rec: Record "Default Dimension"; xRec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        ItemRec: Record Item;
        DefaultDim: Record "Default Dimension";
    begin
        // فقط اگر این رکورد مربوط به Manufacturer باشد
        if (Rec."Table ID" = Database::Manufacturer) then begin
            // پیدا کردن همه آیتم‌هایی که Manufacturer Code آن‌ها برابر با این Manufacturer است
            ItemRec.Reset();
            ItemRec.SetRange("Manufacturer Code", Rec."No.");
            if ItemRec.FindSet() then
                repeat
                    // به‌روزرسانی فقط همان Dimension Code برای آیتم
                    DefaultDim.Reset();
                    DefaultDim.SetRange("Table ID", Database::Item);
                    DefaultDim.SetRange("No.", ItemRec."No.");
                    DefaultDim.SetRange("Dimension Code", Rec."Dimension Code");
                    if DefaultDim.FindFirst() then begin
                        DefaultDim."Dimension Value Code" := Rec."Dimension Value Code";
                        DefaultDim."Value Posting" := Rec."Value Posting";
                        DefaultDim."Allowed Values Filter" := Rec."Allowed Values Filter";
                        DefaultDim.Modify();
                    end;
                until ItemRec.Next() = 0;
        end;
    end;
}
#endregion 123 - Automatic Create Cost Object Base On Brand For Items