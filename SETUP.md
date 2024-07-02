* setup with ansible
* connect to DC and open local group policy editor
* Goto `Local Computer Policy > Administrative Templates > Windows Components >
  Remote Desktop Services > Remote Desktop Session Host > Connections` and
  configure **limit of concurrent sessions** and the **disable single sessions
  restriction**
* maybe also configure a timeout for disconnected sessions

