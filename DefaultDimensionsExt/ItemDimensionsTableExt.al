#region 123 - Automatic Create Cost Object Base On Brand For Items
tableextension 50610 ItemDimensionsTableExt extends "Default Dimension"
{
    fields
    {
        modify("Dimension Code")
        {

            trigger OnAfterValidate()
            var
                GeneralLedgerSetup: Record "General Ledger Setup";
                InventorySetup: Record "Inventory Setup";
                ItemRec: Record Item;
                ManufacturerDim: Record "Default Dimension";
                CostObjectDimCode: Code[20];
                ManufacturerTableID: Integer;
            begin
                InventorySetup.Get();
                if not InventorySetup."Automatic Assign Cost Object" then
                    exit;

                if Rec."Table ID" = Database::Item then begin

                    CostObjectDimCode := 'COST OBJECT';

                    if Rec."Dimension Code" = CostObjectDimCode then begin
                        if ItemRec.Get(Rec."No.") then begin
                            if ItemRec."Manufacturer Code" <> '' then begin
                                ManufacturerTableID := Database::Manufacturer;
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
                    end
                    else begin

                    end;
                end;
            end;


        }

    }
}
#endregion 123 - Automatic Create Cost Object Base On Brand For Items