// pageextension 50610 ManufacturerDimensionPageExt extends "Default Dimensions"
// {
//     trigger OnOpenPage()
//     var
//         InventorySetup: Record "Inventory Setup";
//     begin
//         // Check if "Automatic Assign Cost Object" is enabled
//         InventorySetup.Get();
//         if InventorySetup."Automatic Assign Cost Object" then begin
//             Rec.SetRange("Dimension Code", 'Cost Object');
//         end;
//     end;

//     actions
//     {
//         addlast(Processing)
//         {
//             action("SetCostObject")
//             {
//                 Caption = 'Set Cost Object';
//                 ApplicationArea = All;
//                 trigger OnAction()
//                 begin
//                     if Rec."Dimension Code" = '' then
//                         Rec."Dimension Code" := 'Cost Object';
//                 end;
//             }
//         }
//     }
// }