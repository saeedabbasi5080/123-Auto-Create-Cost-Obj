pageextension 50608 "Manufacturer Card Ext" extends "Manufacturers"
{
    actions
    {
        addlast(Processing)
        {
            group(DimensionsGroup)
            {
                Caption = 'Dimensions';
                Image = Dimensions;
                ToolTip = 'View or edit dimensions related to this manufacturer.';

                action(DimensionSingleAction)
                {
                    ApplicationArea = Dimensions;
                    Caption = 'Dimension-Single';
                    Image = Dimensions;
                    RunObject = page "Default Dimensions";
                    RunPageLink = "Table ID" = const(5720), "No." = field(Code);
                    ToolTip = 'View or edit the single default dimension that is set up for the manufacturer.';

                }
                action(DimensionMultipleAction)
                {
                    ApplicationArea = Dimensions;
                    Caption = 'Dimension-Multiple';
                    Image = DimensionSets;
                    RunObject = page "Default Dimensions-Multiple";
                    RunPageLink = "Table ID" = const(5720), "No." = field(Code);
                    ToolTip = 'View or edit the multiple default dimensions that are set up for the manufacturer.';
                    // trigger OnAction()
                    // var
                    //     // Item: Record Item;
                    //     DefaultDimMultiple: Page "Default Dimensions-Multiple";
                    // begin
                    //     CurrPage.SetSelectionFilter(Rec);
                    //     DefaultDimMultiple.SetMultiRecord(Rec, "No.");
                    //     DefaultDimMultiple.RunModal;
                    // end;
                }
            }
        }

    }
}