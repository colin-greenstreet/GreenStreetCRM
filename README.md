# GreenStreetCRM
CRM Application for Green Street Consulting

Green Street CRM is a basic CRM app for Mac OS that persists data to an SQLite database.

It has four data entities:

Company
Contact - a child of Company
Opportunity - a child of Company and Contact
Action - a child of Opportunity denoting a 'to do' associated with the Opportunity

Each entity has a tableview to view, edit, add and delete. Add and edit accomplished via an Auxilliary view.

Opportunity table view is the apps entry point and shows all Opportunities. The Actions table view can be called for an Opportunity and then only shows Actions for that Opportunity.

The Actions table view allows addition of new Actions, completin of existing Actions and adjusting the due date

Maintenance of Company and Contacts is acheived via table views called from the Reference menu item in the apps main menu. When a Contact is added it is related to a Company.

The app main menu also has a View/Actions menu item that calls the Action table view for all Actions irrespective of Opportunity.

The app follows the MVC design pattern

