# GreenStreetCRM
CRM Application for Green Street Consulting

Green Street CRM is a basic CRM app for Mac OS that persists data to an SQLite database.

It has four data entities:

Company, 
Contact - a child of Company, 
Opportunity - a child of Company and Contact, 
Action - a child of Opportunity denoting a 'to do' associated with the Opportunity.

Each entity has a tableview to view, edit, add and delete. Add and edit accomplished via an Auxilliary view.

Opportunity table view is the apps entry point and shows all Opportunities. The Actions table view can be called for an Opportunity and then only shows Actions for that Opportunity.

The Actions table view allows addition of new Actions, completin of existing Actions and adjusting the due date

Maintenance of Company and Contacts is acheived via table views called from the Reference menu item in the apps main menu. When a Contact is added it is related to a Company.

The app main menu also has a View/Actions menu item that calls the Action table view for all Actions irrespective of Opportunity.

The app follows the MVC design pattern, so it has:

Data entity classes for Company, Contact, Opportunity and Action. These only provide the properties for each data entity.
Data source classes for each of the data entities which perform all interaction with SQLite and deliver all data to the View Controllers
View Controllers for each of the table view based views for each of the four data entities
Auxilliary view controllers for the auxilliary views that handle add and edit for each data entity. Add and edit handled by the same view by passing in a 'mode'. All interaction to the data source classes is delegated to the view controllers
