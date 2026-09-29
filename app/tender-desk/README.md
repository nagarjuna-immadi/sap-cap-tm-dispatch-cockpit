## tender-desk

Tender Desk (blueprint §7, App 2; development plan phase 3): a Fiori elements V4 List
Report and Object Page on `TenderService.OpenInvitations`, for the `CarrierDesk` role.

- **List:** open invitations sorted by quote deadline, with the time left. The deadline is
  yellow under 24 hours and red once expired (evaluated on the server).
- **Object Page:** freight order context from TM (lane, pick-up and delivery dates), then
  *Submit Quote* and *Decline*. Both are only offered while the invitation is `INVITED`.

All UI is annotation-driven (`annotations.cds`); there is no custom code.

### Starting the app

Start the CAP project from the repository root (`cds watch`) and open, as `satish`:

http://localhost:4004/tm.dispatch.tenderdesk/index.html
