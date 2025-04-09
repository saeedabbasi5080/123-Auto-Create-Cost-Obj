codeunit 50603 MySimpleMessageListener0
{

    [EventSubscriber(ObjectType::Page, 542, 'OnBeforeSetCommonDefaultCopyFields', '', false, false)]

    procedure SetMultiRecord0(var DefaultDimension: Record "Default Dimension"; FromDefaultDimension: Record "Default Dimension")

    begin
        Message('saeed0000000');
    end;



}