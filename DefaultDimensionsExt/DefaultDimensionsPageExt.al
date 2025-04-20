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
            Editable = not (RestrictCostObjDimValue and (Rec."Dimension Code" = CostObjectDimCode));
        }
    }

    var
        GenLedgerSetup: Record "General Ledger Setup";
        RestrictCostObjDimValue: Boolean;
        CostObjectDimCode: Code[20];

    trigger OnOpenPage()

    begin
        GenLedgerSetup.Get();
        RestrictCostObjDimValue := GenLedgerSetup."Cost Object Value Read-Only";
        CostObjectDimCode := 'COST OBJECT';
    end;

    trigger OnAfterGetCurrRecord()
    begin
        GenLedgerSetup.Get();
        if Rec."Table ID" = Database::Item then begin
            RestrictCostObjDimValue := GenLedgerSetup."Cost Object Value Read-Only";
        end
        else begin
            RestrictCostObjDimValue := false;
        end;
    end;
}
#endregion 123 - Automatic Create Cost Object Base On Brand For Items