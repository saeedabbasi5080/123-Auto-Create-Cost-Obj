#region 123 - Automatic Create Cost Object Base On Brand For Items
tableextension 50612 GeneralLedgerSetupTblExt extends "General Ledger Setup"
{
    fields
    {
        field(50100; "Cost Object Value Read-Only"; Boolean)
        {
            Caption = 'Cost Object Value Read-Only';
        }
        field(50101; "Dimension Consistency"; Boolean)
        {
            Caption = 'Dimension Consistency ';
        }
    }
}
#endregion 123 - Automatic Create Cost Object Base On Brand For Items