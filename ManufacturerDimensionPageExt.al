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
                    // Promoted = true;
                    // PromotedCategory = Process;
                    RunObject = page "Default Dimensions";
                    RunPageLink = "Table ID" = const(27), "No." = field(Code);
                    ToolTip = 'View or edit the single default dimension that is set up for the manufacturer.';


                    trigger OnAction()
                    // var
                    //     DefaultDim: Record "Default Dimension";
                    //     DimensionManagement: Codeunit DimensionManagement;
                    //     RecRef: RecordRef;
                    begin
                        // Use Dimension Management codeunit for standard functionality
                        // RecRef.GetTable(Rec);
                        // DimensionManagement.ShowDefaultDimensions(RecRef);

                        // Alternative direct way (less common now):
                        // DefaultDim.SetSource(Database::Manufacturer, Rec.Code);
                        // DimensionManagement.ShowDefaultDimensions(DefaultDim);
                    end;
                }
                action(DimensionMultipleAction)
                {
                    ApplicationArea = Dimensions;
                    Caption = 'Dimension-Multiple';
                    Image = DimensionSets;
                    ToolTip = 'View or edit the dimension set entries linked to this manufacturer.';

                    trigger OnAction()
                    // var
                    //     RecRef: RecordRef;
                    //     DimensionManagement: Codeunit DimensionManagement;
                    begin
                        // RecRef.GetTable(Rec);
                        // DimensionManagement.ShowDimensionSetEntries(RecRef);

                        // Alternative (if ShowDimensionSetEntries is not suitable):
                        // PAGE.RunModal(PAGE::"Dimension Set Entries", RecRef.RecordId);
                    end;
                }
            }
        }

    }
}