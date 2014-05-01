<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>International_Address</fullName>
        <description>Checks this box for non-us addresses</description>
        <field>International_Address__c</field>
        <literalValue>1</literalValue>
        <name>International Address</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>International_Uncheck</fullName>
        <field>International_Address__c</field>
        <literalValue>0</literalValue>
        <name>International Uncheck</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PO_Box</fullName>
        <description>Checks the PO Box if address is a PO Box</description>
        <field>PO_Box__c</field>
        <literalValue>1</literalValue>
        <name>PO Box</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PO_Box_Check</fullName>
        <description>Checks the PO BOX? field</description>
        <field>PO_Box__c</field>
        <literalValue>1</literalValue>
        <name>PO Box</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PO_Box_Update</fullName>
        <description>Checks the PO Box checkbox</description>
        <field>PO_Box__c</field>
        <literalValue>1</literalValue>
        <name>PO Box</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PO_Uncheck</fullName>
        <field>PO_Box__c</field>
        <literalValue>0</literalValue>
        <name>PO_Uncheck</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>International Address</fullName>
        <actions>
            <name>International_Address</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Address__c.Country__c</field>
            <operation>notEqual</operation>
            <value>US,USA,UNITED STATES,UNITES STATES OF AMERICA</value>
        </criteriaItems>
        <description>This rule checks the &quot;International Address?&quot; Checkbox for Non-US Addresses.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>International Uncheck</fullName>
        <actions>
            <name>International_Uncheck</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Address__c.Country__c</field>
            <operation>notContain</operation>
            <value>US,USA,UNITED STATES,UNITES STATES OF AMERICA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Address__c.Country__c</field>
            <operation>notEqual</operation>
            <value>NULL</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PO Box</fullName>
        <actions>
            <name>PO_Box_Check</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Address__c.Address_Line_1__c</field>
            <operation>contains</operation>
            <value>PO Box,P.O,P.O.</value>
        </criteriaItems>
        <description>This rule checks the &quot;PO BOX?&quot; field if the address is a PO BOX</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PO_Uncheck</fullName>
        <actions>
            <name>PO_Uncheck</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Address__c.Address_Line_1__c</field>
            <operation>notContain</operation>
            <value>PO,P.O,P.O.</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
