// // File: src/Codeunit/COD50100.ItemDimAutomationMgt.al
// codeunit 50600 "Item Dim Automation Mgt"
// {
//     procedure AssignCostObjectToItem(var Item: Record Item)
//     var
//         Manufacturer: Record Manufacturer;
//         DimensionManagement: Codeunit "DimensionManagement";
//         ItemDimensionValue: Record "Dimension Value";
//         ManufacturerDimensionValue: Record "Dimension Value";
//         DimensionValue: Record "Dimension Value";
//         DefaultDimension: Record "Default Dimension";
//         InventorySetup: Record "Inventory Setup";
//     begin
//         InventorySetup.Get();
//         if not InventorySetup."Automatic Assign Cost Object" then
//             exit;

//         if Item."Manufacturer Code" = '' then begin
//             // Remove existing Cost Object dimension if manufacturer is cleared
//             RemoveCostObjectDimension(Item);
//             exit;
//         end;

//         if not Manufacturer.Get(Item."Manufacturer Code") then
//             exit;

//         // Find the Cost Object dimension value for this manufacturer
//         if not FindManufacturerCostObjectDimension(Manufacturer, ManufacturerDimensionValue) then
//             exit;

//         // Check if item already has this dimension
//         if ItemHasCostObjectDimension(Item, ManufacturerDimensionValue) then
//             exit;

//         // Remove any existing Cost Object dimension first
//         RemoveCostObjectDimension(Item);

//         // Add the new Cost Object dimension
//         DefaultDimension.Init();
//         DefaultDimension."Table ID" := Database::Item;
//         DefaultDimension."No." := Item."No.";
//         DefaultDimension."Dimension Code" := ManufacturerDimensionValue."Dimension Code";
//         DefaultDimension."Dimension Value Code" := ManufacturerDimensionValue.Code;
//         DefaultDimension."Value Posting" := DefaultDimension."Value Posting"::"Code Mandatory";
//         if not DefaultDimension.Insert() then
//             DefaultDimension.Modify();
//     end;

//     local procedure FindManufacturerCostObjectDimension(Manufacturer: Record Manufacturer; var DimensionValue: Record "Dimension Value"): Boolean
//     var
//         DefaultDimension: Record "Default Dimension";
//         Dimension: Record Dimension;
//     begin
//         Dimension.SetRange(Code, 'COSTOBJECT');
//         if not Dimension.FindFirst() then
//             exit(false);

//         DefaultDimension.SetRange("Table ID", Database::Manufacturer);
//         DefaultDimension.SetRange("No.", Manufacturer.Code);
//         DefaultDimension.SetRange("Dimension Code", Dimension.Code);
//         if not DefaultDimension.FindFirst() then
//             exit(false);

//         exit(DimensionValue.Get(Dimension.Code, DefaultDimension."Dimension Value Code"));
//     end;

//     local procedure ItemHasCostObjectDimension(Item: Record Item; DimensionValue: Record "Dimension Value"): Boolean
//     var
//         DefaultDimension: Record "Default Dimension";
//     begin
//         DefaultDimension.SetRange("Table ID", Database::Item);
//         DefaultDimension.SetRange("No.", Item."No.");
//         DefaultDimension.SetRange("Dimension Code", DimensionValue."Dimension Code");
//         DefaultDimension.SetRange("Dimension Value Code", DimensionValue.Code);
//         exit(not DefaultDimension.IsEmpty());
//     end;

//     local procedure RemoveCostObjectDimension(Item: Record Item)
//     var
//         DefaultDimension: Record "Default Dimension";
//         Dimension: Record Dimension;
//     begin
//         Dimension.SetRange(Code, 'COSTOBJECT');
//         if not Dimension.FindFirst() then
//             exit;

//         DefaultDimension.SetRange("Table ID", Database::Item);
//         DefaultDimension.SetRange("No.", Item."No.");
//         DefaultDimension.SetRange("Dimension Code", Dimension.Code);
//         if not DefaultDimension.IsEmpty() then
//             DefaultDimension.DeleteAll();
//     end;
// }