Class {
	#name : #SPClass,
	#superclass : #Object,
	#instVars : [
		'name',
		'outgoingRelations',
		'incomingRelations'
	],
	#category : #Spinoza
}

{ #category : #adding }
SPClass >> addIncomingRelation: aSPRelation [

	incomingRelations add: aSPRelation
]

{ #category : #adding }
SPClass >> addOutgoingRelation: aSPRelation [

	outgoingRelations add: aSPRelation
]

{ #category : #accessing }
SPClass >> incomingRelations [
	^ incomingRelations
]

{ #category : #accessing }
SPClass >> initialize [

	super initialize.
	outgoingRelations := OrderedCollection new.
	incomingRelations := OrderedCollection new
]

{ #category : #accessing }
SPClass >> name [ 
	 ^ name 
]

{ #category : #accessing }
SPClass >> name: aString [ 
	name := aString
]

{ #category : #accessing }
SPClass >> outgoingRelations [
	^ outgoingRelations
]

{ #category : #accessing }
SPClass >> printOn: aStream [

	aStream
		nextPutAll: 'class: ';
		nextPutAll: name
]
