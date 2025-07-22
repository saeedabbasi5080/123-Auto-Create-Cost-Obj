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
        CostObjectDimCode: Code[20];
        ManufacturerTableID: Integer;
    begin
        InventorySetup.Get();
        if not InventorySetup."Automatic Assign Cost Object" then
            exit;
        CostObjectDimCode := 'COST OBJECT';
        ManufacturerTableID := Database::Manufacturer;
        // Remove previous Cost Object if Manufacturer Code is changed or deleted
        DefaultDim.Reset();
        DefaultDim.SetRange("Table ID", Database::Item);
        DefaultDim.SetRange("No.", Rec."No.");
        DefaultDim.SetRange("Dimension Code", CostObjectDimCode);
        if DefaultDim.FindFirst() then
            DefaultDim.Delete();
        // If new Manufacturer Code exists, add the new Cost Object
        if Rec."Manufacturer Code" <> '' then begin
            ManufacturerDim.Reset();
            ManufacturerDim.SetRange("Table ID", ManufacturerTableID);
            ManufacturerDim.SetRange("No.", Rec."Manufacturer Code");
            ManufacturerDim.SetRange("Dimension Code", CostObjectDimCode);
            if ManufacturerDim.FindFirst() then begin
                DefaultDim.Init();
                DefaultDim."Table ID" := Database::Item;
                DefaultDim."No." := Rec."No.";
                DefaultDim."Dimension Code" := CostObjectDimCode;
                DefaultDim."Dimension Value Code" := ManufacturerDim."Dimension Value Code";
                DefaultDim."Value Posting" := ManufacturerDim."Value Posting";
                DefaultDim."Allowed Values Filter" := ManufacturerDim."Allowed Values Filter";
                DefaultDim.Insert();
            end;
        end;
    end;
}
#endregion 123 - Automatic Create Cost Object Base On Brand For Items