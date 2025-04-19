// page 50100 "Manufacturer Page"
// {
//     // دیگر تنظیمات صفحه مانند عنوان، فیلدها و ...

//     trigger OnModify()
//     var
//         ItemRec: Record Item;
//         DimensionRec: Record "Dimension Value";
//     begin
//         // ابتدا بررسی می‌کنیم که آیا کد دایمنشن تغییر کرده یا نه
//         if "Dimension Code" <> OldRec."Dimension Code" then begin
//             // تغییرات دایمنشن در صفحه Manufacturer اعمال می‌شود
//             // برای تغییرات دایمنشن در آیتم‌ها باید به رکورد Item دسترسی پیدا کنیم

//             if "Manufacturer Code" <> '' then begin
//                 // فرض می‌کنیم که Manufacturer Code در آیتم‌ها ذخیره می‌شود و با این کدها به رکورد آیتم دسترسی داریم
//                 if ItemRec.Get("Manufacturer Code") then begin
//                     // اینجا تغییرات جدید دایمنشن را روی رکورد آیتم اعمال می‌کنیم
//                     ItemRec."Dimension Code" := "Dimension Code";
//                     ItemRec."Dimension Value Code" := "Dimension Value Code";
//                     ItemRec.Modify(); // تغییرات را ذخیره می‌کنیم
//                 end;
//             end;
//         end;
//     end;
// }
