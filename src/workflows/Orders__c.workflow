<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Perfectly_Pure_Order_Confirmation_Autoresponder</fullName>
        <description>Perfectly Pure Order Confirmation Autoresponder</description>
        <protected>false</protected>
        <recipients>
            <field>Order_Confirm_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>customerservice@perfectlypure.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AR_Email_Templates/Perfectly_Pure_Phone_Order_Confirmation</template>
    </alerts>
    <alerts>
        <fullName>Puritan_s_Pride_Order_Confirmation_Autoresponder</fullName>
        <description>Puritan&apos;s Pride Order Confirmation Autoresponder</description>
        <protected>false</protected>
        <recipients>
            <field>Order_Confirm_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>customerservice@puritan.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AR_Email_Templates/Puritan_s_Pride_Phone_Order_Confirmation</template>
    </alerts>
    <alerts>
        <fullName>Vitamin_World_Phone_Order_Email_Confirmation</fullName>
        <description>Vitamin World Phone Order Email Confirmation</description>
        <protected>false</protected>
        <recipients>
            <field>Order_Confirm_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>customerservice@vitaminworld.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AR_Email_Templates/VItamin_World_Phone_Order_Confirmation</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approved_Status</fullName>
        <field>Order_Status__c</field>
        <literalValue>Pending Submission</literalValue>
        <name>Approved Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Fraud_Review</fullName>
        <field>Order_Status__c</field>
        <literalValue>Internal Review</literalValue>
        <name>Fraud Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Internal_Review_Reason</fullName>
        <description>Set the &quot;Internal Review Reason&quot; as &quot;Order Over $5,000&quot;</description>
        <field>Internal_Review_Reason__c</field>
        <literalValue>Order Over $5,000</literalValue>
        <name>Internal Review Reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Internal_Review_Reason_Possible_Fraud</fullName>
        <field>Internal_Review_Reason__c</field>
        <literalValue>Possible Fraud</literalValue>
        <name>Internal Review Reason Possible Fraud</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OrderStatusUpdate</fullName>
        <description>Update order status to pending submission</description>
        <field>Order_Status__c</field>
        <literalValue>Pending Submission</literalValue>
        <name>Order Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Order_Status</fullName>
        <description>Set the Order Status as &quot;Internal Review</description>
        <field>Order_Status__c</field>
        <literalValue>Internal Review</literalValue>
        <name>Order Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Order_Status_Ship_Complete</fullName>
        <field>Order_Status__c</field>
        <literalValue>Internal Review</literalValue>
        <name>Order Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Customer_Name_on_Order_for_Phon</fullName>
        <field>Customer_Name__c</field>
        <formula>Customer__r.FirstName +&apos; &apos;+ Customer__r.LastName</formula>
        <name>Populate Customer Name on Order for Phon</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Replacement_Approval</fullName>
        <field>Order_Status__c</field>
        <literalValue>Pending Submission</literalValue>
        <name>Replacement Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Replacement_Approval_Submission</fullName>
        <field>Order_Status__c</field>
        <literalValue>Awaiting Approval</literalValue>
        <name>Replacement Approval Submission</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Replacement_Approved</fullName>
        <field>Order_Status__c</field>
        <literalValue>Pending Submission</literalValue>
        <name>Replacement Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Replacement_Awaiting_Approval</fullName>
        <field>Order_Status__c</field>
        <literalValue>Awaiting Approval</literalValue>
        <name>Replacement Awaiting Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Replacement_Rejected</fullName>
        <field>Order_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Replacement Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Replacement_Rejection</fullName>
        <field>Order_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Replacement Rejection</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Replacement_Temp</fullName>
        <field>Replacement_Order__c</field>
        <literalValue>0</literalValue>
        <name>Replacement Temp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Replacements_Awaiting_Approval</fullName>
        <field>Order_Status__c</field>
        <literalValue>Awaiting Approval</literalValue>
        <name>Replacements Awaiting Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Ship_Complete_Internal_Review_Reason_Upd</fullName>
        <field>Internal_Review_Reason__c</field>
        <literalValue>Ship Complete was checked</literalValue>
        <name>Ship Complete Internal Review Reason Upd</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Owner_to_Awaiting_on_Payments_Q</fullName>
        <field>OwnerId</field>
        <lookupValue>Awaiting_Physical_Payment</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update Owner to Awaiting on Payments Q</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>test</fullName>
        <apiVersion>28.0</apiVersion>
        <endpointUrl>http://www.nbty.com</endpointUrl>
        <fields>Amazon_ID__c</fields>
        <fields>Authorization_Amount__c</fields>
        <fields>Bill_To_Address_Details__c</fields>
        <fields>CTI_Search__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>rbadal@nbty.com</integrationUser>
        <name>test</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Internal Review %245%2C000</fullName>
        <actions>
            <name>Internal_Review_Reason</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Order_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND (3 OR 4)</booleanFilter>
        <criteriaItems>
            <field>Orders__c.Calculated_Order_Total__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 5,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Orders__c.Order_Status__c</field>
            <operation>equals</operation>
            <value>Pending Submission</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>CSR</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>WebStack Integration</value>
        </criteriaItems>
        <description>Automatically sets the Order Status to &quot;Internal Review&quot; when the Order Total is greater than $5,000</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Internal Review Possible Fraud</fullName>
        <actions>
            <name>Internal_Review_Reason_Possible_Fraud</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Order_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND (3 OR 4)</booleanFilter>
        <criteriaItems>
            <field>Orders__c.Customer_Fraud_Risk__c</field>
            <operation>equals</operation>
            <value>YES</value>
        </criteriaItems>
        <criteriaItems>
            <field>Orders__c.Order_Status__c</field>
            <operation>equals</operation>
            <value>Pending Submission</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>CSR</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>WebStack Integration</value>
        </criteriaItems>
        <description>Automatically sets the Order Status to &quot;Internal Review&quot; when Customer Fraud Risk? is &quot;Yes&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Internal Review Ship Complete</fullName>
        <actions>
            <name>Order_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Ship_Complete_Internal_Review_Reason_Upd</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Orders__c.Order_Status__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <criteriaItems>
            <field>Orders__c.Ship_Complete__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Move Waiting on Physical Payment Order into Queue</fullName>
        <actions>
            <name>Update_Owner_to_Awaiting_on_Payments_Q</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Orders__c.Order_Status__c</field>
            <operation>equals</operation>
            <value>Awaiting Physical Payment</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PayPal Orders To Internal Review</fullName>
        <actions>
            <name>Internal_Review_Reason_Possible_Fraud</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Order_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Orders__c.Payment_Type__c</field>
            <operation>equals</operation>
            <value>Paypal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Orders__c.Calculated_Order_Total__c</field>
            <operation>greaterOrEqual</operation>
            <value>USD 300</value>
        </criteriaItems>
        <description>Any order with a value of $300.00 or more and for PayPal payment type are to go to internal review.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Perfectly Pure Phone Order Confirmation</fullName>
        <actions>
            <name>Perfectly_Pure_Order_Confirmation_Autoresponder</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Orders__c.Order_Status__c</field>
            <operation>equals</operation>
            <value>Pending Submission</value>
        </criteriaItems>
        <criteriaItems>
            <field>Orders__c.Sales_Channel__c</field>
            <operation>equals</operation>
            <value>Phone</value>
        </criteriaItems>
        <criteriaItems>
            <field>Orders__c.Order_Confirm_Brand__c</field>
            <operation>equals</operation>
            <value>Perfectly Pure</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Email</field>
            <operation>notContain</operation>
            <value>@marketplace.amazon.com</value>
        </criteriaItems>
        <description>Workflow fires to email order confirmation</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Customer Name on Order for Phone Orders</fullName>
        <actions>
            <name>Populate_Customer_Name_on_Order_for_Phon</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Orders__c.Sales_Channel__c</field>
            <operation>equals</operation>
            <value>Phone</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Puritan%27s Pride Phone Order Confirmation</fullName>
        <actions>
            <name>Puritan_s_Pride_Order_Confirmation_Autoresponder</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Orders__c.Order_Status__c</field>
            <operation>equals</operation>
            <value>Pending Submission</value>
        </criteriaItems>
        <criteriaItems>
            <field>Orders__c.Sales_Channel__c</field>
            <operation>equals</operation>
            <value>Phone</value>
        </criteriaItems>
        <criteriaItems>
            <field>Orders__c.Order_Confirm_Brand__c</field>
            <operation>equals</operation>
            <value>Puritan&apos;s Pride</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Email</field>
            <operation>notContain</operation>
            <value>@marketplace.amazon.com</value>
        </criteriaItems>
        <description>Workflow fires to email order confirmation</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Replacement Orders to pending submission</fullName>
        <actions>
            <name>OrderStatusUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Orders__c.Order_Total__c</field>
            <operation>equals</operation>
            <value>USD 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Orders__c.Replacement_Order__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>If a replacement order has a total of $0 and is marked as replacement skip internal review.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Test</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Orders__c.Order_Total__c</field>
            <operation>equals</operation>
            <value>&quot;USD 1,000&quot;</value>
        </criteriaItems>
        <description>Test</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Vitamin World Phone Order Confirmation</fullName>
        <actions>
            <name>Vitamin_World_Phone_Order_Email_Confirmation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Orders__c.Order_Status__c</field>
            <operation>equals</operation>
            <value>Pending Submission</value>
        </criteriaItems>
        <criteriaItems>
            <field>Orders__c.Order_Confirm_Brand__c</field>
            <operation>equals</operation>
            <value>Vitamin World</value>
        </criteriaItems>
        <criteriaItems>
            <field>Orders__c.Sales_Channel__c</field>
            <operation>equals</operation>
            <value>Phone</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Email</field>
            <operation>notContain</operation>
            <value>@marketplace.amazon.com</value>
        </criteriaItems>
        <description>Workflow fires to email order confirmation</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
