#region CRID 123 - Automatic Create Cost Object Base On Brand For Items
pageextension 50612 DefaultDimensionsPageExt extends "Default Dimensions"
{
    layout
    {
        modify("Dimension Value Code")
        {
            Editable = IsCostObjectEditable;
        }
        modify("Value Posting")
        {
            Editable = IsCostObjectEditable;
        }
        modify("AllowedValuesFilter")
        {
            Editable = not IsCostObjectEditable;
        }
    }
    var
        GenLedgerSetup: Record "General Ledger Setup";
        ItemRec: Record Item;
        ManufacturerDim: Record "Default Dimension";
        RestrictCostObjDimValue: Boolean;
        CostObjectDimCode: Code[20];
        ManufacturerTableID: Integer;
        IsCostObjectEditable: Boolean;

    trigger OnOpenPage()
    begin
        SetCostObjectEditability();
    end;

    trigger OnAfterGetRecord()
    begin
        SetCostObjectValuesFromManufacturer();
    end;

    local procedure SetCostObjectEditability()
    begin
        GenLedgerSetup.Get();
        if Rec."Table ID" = Database::Item then
            RestrictCostObjDimValue := GenLedgerSetup."Cost Object Value Read-Only";
        CostObjectDimCode := 'COST OBJECT';
        ManufacturerTableID := Database::Manufacturer;
        IsCostObjectEditable := not (RestrictCostObjDimValue and (Rec."Dimension Code" = CostObjectDimCode));
    end;

    local procedure SetCostObjectValuesFromManufacturer()
    var
        InventorySetup: Record "Inventory Setup";
    begin
        GenLedgerSetup.Get();

        if Rec."Table ID" = Database::Item then
            RestrictCostObjDimValue := GenLedgerSetup."Cost Object Value Read-Only"
        else
            RestrictCostObjDimValue := false;

        InventorySetup.Get();
        if not InventorySetup."Automatic Assign Cost Object" then
            exit;

        if Rec."Table ID" = Database::Item then
            if Rec."Dimension Code" = CostObjectDimCode then
                if ItemRec.Get(Rec."No.") then
                    if ItemRec."Manufacturer Code" <> '' then begin
                        ManufacturerDim.Reset();
                        ManufacturerDim.SetRange("Table ID", ManufacturerTableID);
                        ManufacturerDim.SetRange("No.", ItemRec."Manufacturer Code");
                        ManufacturerDim.SetRange("Dimension Code", CostObjectDimCode);

                        if ManufacturerDim.FindFirst() then begin
                            Rec."Dimension Value Code" := ManufacturerDim."Dimension Value Code";
                            Rec."Value Posting" := ManufacturerDim."Value Posting";
                            Rec."Allowed Values Filter" := ManufacturerDim."Allowed Values Filter";
                        end else
                            Rec."Dimension Value Code" := '';
                    end else
                        Rec."Dimension Value Code" := '';

        IsCostObjectEditable := not (RestrictCostObjDimValue and (Rec."Dimension Code" = CostObjectDimCode));
    end;
}
#endregion CRID 123 - Automatic Create Cost Object Base On Brand For Items