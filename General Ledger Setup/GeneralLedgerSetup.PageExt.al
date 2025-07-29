#region CRID 123 - Automatic Create Cost Object Base On Brand For Items
pageextension 50611 GeneralLedgerSetupPageExt extends "General Ledger Setup"
{
    layout
    {
        addlast(General)
        {
            field("Cost Object Value Read-Only"; Rec."Cost Object Value Read-Only")
            {
                Caption = 'Cost Object Value Read-Only';
                ApplicationArea = All;
            }
        }
    }
}
#endregion CRID 123 - Automatic Create Cost Object Base On Brand For Items