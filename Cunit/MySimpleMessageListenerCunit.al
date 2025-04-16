codeunit 50602 MySimpleMessageListener
{
    [EventSubscriber(ObjectType::Codeunit, 408, 'OnAfterDefaultDimObjectNoWithoutGlobalDimsList', '', false, false)]
    local procedure ShowMessageOnAfterSetupObjectNoList(var TempAllObjWithCaption: Record AllObjWithCaption temporary)
    var
        DimensionManagement: Codeunit "DimensionManagement";
    begin
        DimensionManagement.DefaultDimInsertTempObject(TempAllObjWithCaption, Database::"Manufacturer");
    end;
}

// کد یونتیتی می باشد که Manufacturer را در جدول TempAllObjWithCaption اضافه می کند