#region 123 - Automatic Create Cost Object Base On Brand For Items
pageextension 50612 DefaultDimensionsPageExt extends "Default Dimensions"
{
    layout
    {
        modify("Dimension Value Code")
        {
            Editable = not (RestrictCostObjDimValue and (Rec."Dimension Code" = CostObjectDimCode));
        }
        modify("Value Posting")
        {
            Editable = not (RestrictCostObjDimValue and (Rec."Dimension Code" = CostObjectDimCode));
        }
        modify("AllowedValuesFilter")
        {
            Editable = (RestrictCostObjDimValue and (Rec."Dimension Code" = CostObjectDimCode));

        }
    }

    var
        GenLedgerSetup: Record "General Ledger Setup";
        ItemRec: Record Item;
        ManufacturerDim: Record "Default Dimension";
        RestrictCostObjDimValue: Boolean;
        CostObjectDimCode: Code[20];
        ManufacturerTableID: Integer;

    trigger OnOpenPage()
    begin
        GenLedgerSetup.Get();
        if Rec."Table ID" = Database::Item then begin
            RestrictCostObjDimValue := GenLedgerSetup."Cost Object Value Read-Only";
        end;
        CostObjectDimCode := 'COST OBJECT';
        ManufacturerTableID := Database::Manufacturer;

        // Filter to show only COST OBJECT dimension for Items
        // if Rec."Table ID" = Database::Item then begin
        //     Rec.SetRange("Dimension Code", CostObjectDimCode);
        // end;
    end;


    trigger OnAfterGetRecord()
    var
        InventorySetup: Record "Inventory Setup";
    begin
        GenLedgerSetup.Get();

        if Rec."Table ID" = Database::Item then begin
            RestrictCostObjDimValue := GenLedgerSetup."Cost Object Value Read-Only";
        end
        else begin
            RestrictCostObjDimValue := false;
        end;

        // This code is handled in the main codeunit
    end;
}
#endregion 123 - Automatic Create Cost Object Base On Brand For Items