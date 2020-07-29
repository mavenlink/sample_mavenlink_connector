# Mavenlink Sample Connector

## This is a sample implementation of a gRPC connector that will work Mavenlink Workflows Platform

### Try it out
 - This connector can be run locally with `ruby lib/server.rb`
   - it will be running on `localhost:50055`
 - You can register the local connector with Mavenlink Workflows by going to your Workflows library and clicking the button labeled "Register Connector"
   - use the url `localhost:50055` 
 - When you register a connector your Triggers and Actions will appear in the library
   - The Trigger is named "Invoice Paid".
   - The Action is called "Close Project".

## Example
- Create a new Workflow.
- Set the Trigger of this new Workflow to be "Invoice Paid".
  - This Trigger returns paid invoices and the associated project_ids.
- Add a new Action to the Workflow.
- Select the Action "Close Project".
  - "Close Project" has two inputs Project ID and App Account.
  - Get the Project ID from the Trigger by changing Constant to Trigger Event in the dropdown then select Project ID.
  - Set the App Account to be your same App Account from the Trigger.
- You can see this Workflow in action enabling the Workflow and then marking an invoice as "paid" in Mavenlink (Warning: This will archive the project).
- You will see a successful run in the Workflows History page of the Workflow.
  
  _Note: After successfully registering your connector if you turn off your local connector those Triggers and Actions will remain registered in Mavenlink Workflows. However, you will see gRPC Timeout errors being logged in the Managers Health dashboard if you have an enabled workflow using those Triggers and Actions._