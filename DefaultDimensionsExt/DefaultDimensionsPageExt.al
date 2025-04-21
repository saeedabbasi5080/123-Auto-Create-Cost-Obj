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
    end;


    trigger OnAfterGetRecord()
    begin
        GenLedgerSetup.Get();

        if Rec."Table ID" = Database::Item then begin
            RestrictCostObjDimValue := GenLedgerSetup."Cost Object Value Read-Only";
        end
        else begin
            RestrictCostObjDimValue := false;
        end;

        if Rec."Table ID" = Database::Item then begin
            if Rec."Dimension Code" = CostObjectDimCode then begin
                if ItemRec.Get(Rec."No.") then begin
                    if ItemRec."Manufacturer Code" <> '' then begin
                        ManufacturerDim.Reset();
                        ManufacturerDim.SetRange("Table ID", ManufacturerTableID);
                        ManufacturerDim.SetRange("No.", ItemRec."Manufacturer Code");
                        ManufacturerDim.SetRange("Dimension Code", CostObjectDimCode);

                        if ManufacturerDim.FindFirst() then begin
                            Rec."Dimension Value Code" := ManufacturerDim."Dimension Value Code";
                            Rec."Value Posting" := ManufacturerDim."Value Posting";
                            Rec."Allowed Values Filter" := ManufacturerDim."Allowed Values Filter";
                        end
                        else begin
                            Rec."Dimension Value Code" := '';
                        end;
                    end
                    else begin
                        Rec."Dimension Value Code" := '';
                    end;
                end;
            end;
        end;
    end;
}




#endregion 123 - Automatic Create Cost Object Base On Brand For Items