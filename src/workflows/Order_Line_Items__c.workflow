<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>BO_Perfectly_Pure_Order_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>BO_Perfectly_Pure_Order</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>BO - Perfectly Pure - Order Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <targetObject>Order__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BO_Puritan_s_Pride</fullName>
        <field>OwnerId</field>
        <lookupValue>BO_Puritan_s_Pride_Order</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>BO Puritan&apos;s Pride</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <targetObject>Order__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BO_Puritan_s_Pride_Order_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>BO_Puritan_s_Pride_Order</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>BO - Puritan&apos;s Pride - Order Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <targetObject>Order__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BO_Vitamin_World_Order_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>BO_Vitamin_World_Order</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>BO - Vitamin World - Order Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <targetObject>Order__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Internal_Review_Order_Status</fullName>
        <field>Order_Status__c</field>
        <literalValue>Internal Review</literalValue>
        <name>Internal Review Order Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Order__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Internal_Review_Reason_100_Items</fullName>
        <description>Set the &quot;Internal Review Reason&quot; as &quot;Over 100 of an Item&quot;</description>
        <field>Internal_Review_Reason__c</field>
        <literalValue>Over 100 of a Single Item</literalValue>
        <name>Internal Review Reason 100 Items</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Order__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Internal_Review_Ship_Complete_Order_Stat</fullName>
        <field>Internal_Review_Reason__c</field>
        <literalValue>Ship Complete was checked</literalValue>
        <name>Internal Review Ship Complete Order Stat</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Order__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Order_Status_Update</fullName>
        <description>Set the Order Status as &quot;Internal Review</description>
        <field>Order_Status__c</field>
        <literalValue>Internal Review</literalValue>
        <name>Order Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Order__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Orders_with_Order_Status_Internal_Revie</fullName>
        <field>OwnerId</field>
        <lookupValue>BO_Perfectly_Pure_Order</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Orders with Order Status &quot;Internal Revie</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <targetObject>Order__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Shipped_Complete</fullName>
        <field>Shipped_Complete__c</field>
        <literalValue>1</literalValue>
        <name>Shipped Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Internal Review 100 of a Single Item</fullName>
        <actions>
            <name>Internal_Review_Reason_100_Items</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Order_Status_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND (3 OR 4)</booleanFilter>
        <criteriaItems>
            <field>Order_Line_Items__c.Product_Quantity__c</field>
            <operation>greaterOrEqual</operation>
            <value>100</value>
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
        <description>Automatically sets the Order Status to &quot;Internal Review&quot; when an Order has more than 100 of a Single Item</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send to BO - Perfectly Pure - Order Queue</fullName>
        <actions>
            <name>BO_Perfectly_Pure_Order_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Orders_with_Order_Status_Internal_Revie</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Orders__c.Order_Status__c</field>
            <operation>equals</operation>
            <value>Internal Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order_Line_Items__c.Item_Suffix__c</field>
            <operation>equals</operation>
            <value>0021</value>
        </criteriaItems>
        <description>Orders with Order Status &quot;Internal Review&quot; and Brand &quot;Perfectly Pure&quot; will be sent to the Back Office Perfectly Pure Order Queue.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send to BO - Puritan%27s Pride - Order Queue</fullName>
        <actions>
            <name>BO_Puritan_s_Pride_Order_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Orders__c.Order_Status__c</field>
            <operation>equals</operation>
            <value>Internal Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order_Line_Items__c.Item_Suffix__c</field>
            <operation>equals</operation>
            <value>0011</value>
        </criteriaItems>
        <description>Orders with Order Status &quot;Internal Review&quot; and Brand &quot;Puritan&apos;s Pride&quot; will be sent to the Back Office Puritan&apos;s Pride Order Queue.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send to BO - Vitamin World - Order Queue</fullName>
        <actions>
            <name>BO_Vitamin_World_Order_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Orders__c.Order_Status__c</field>
            <operation>equals</operation>
            <value>Internal Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order_Line_Items__c.Item_Suffix__c</field>
            <operation>equals</operation>
            <value>0070</value>
        </criteriaItems>
        <description>Orders with Order Status &quot;Internal Review&quot; and Brand &quot;Vitamin World&quot; will be sent to the Back Office Vitamin World Order Queue.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Shipped Complete</fullName>
        <actions>
            <name>Shipped_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>IF(Product_Quantity__c  =  Quantity_Shipped__c, true, false)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
