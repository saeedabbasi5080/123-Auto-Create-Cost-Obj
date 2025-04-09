codeunit 50602 MySimpleMessageListener // یا هر ID و نام دیگری که استفاده کردید
{
    // **مهم:** لطفاً YourPublisherObjectTypeId را با ID واقعی آبجکتی که رویداد را منتشر می‌کند جایگزین کنید
    [EventSubscriber(ObjectType::Codeunit, 408, 'OnAfterDefaultDimObjectNoWithoutGlobalDimsList', '', false, false)]
    // ***** تغییر در اینجا اعمال شده است *****
    local procedure ShowMessageOnAfterSetupObjectNoList(var TempAllObjWithCaption: Record AllObjWithCaption temporary)
    // ***** نام رکورد دقیقاً مانند تعریف رویداد اصلی شد *****
    var
        DimensionManagement: Codeunit "DimensionManagement";
    begin
        DimensionManagement.DefaultDimInsertTempObject(TempAllObjWithCaption, Database::"Manufacturer");
    end;
}

// codeunit 50603 AnotherEventListener // یک ID و نام مناسب و جدید برای Codeunit خود انتخاب کنید
// {
//     // این تابع به رویداد OnAfterSetSourceCodeWithVar گوش می‌دهد
//     // **مهم:** لطفاً YourPublisherObjectTypeId را با ID واقعی آبجکتی که رویداد را منتشر می‌کند جایگزین کنید
//     [EventSubscriber(ObjectType::Codeunit, 408, 'OnAfterSetSourceCodeWithVar', '', false, false)]
//     local procedure ShowMessageOnAfterSetSourceCodeWithVar(TableID: Integer; RecordVar: Variant; var SourceCode: Code[10])
//     begin
//         // فقط یک پیام ساده نمایش می‌دهد
//         Message('رویداد OnAfterSetSourceCodeWithVar اجرا شد! TableID: %1', TableID);
//         // می توانید اطلاعات بیشتری را در پیام نمایش دهید، مثلاً TableID
//     end;
// }

