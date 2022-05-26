Class {
	#name : #SPRelationKind,
	#superclass : #Object,
	#instVars : [
		'name'
	],
	#category : #Spinoza
}

{ #category : #testing }
SPRelationKind >> isKindOf [

	^ name = 'Is A'
]

{ #category : #accessing }
SPRelationKind >> name [
	^ name
]

{ #category : #accessing }
SPRelationKind >> name: aString [ 
	name := aString
]

{ #category : #accessing }
SPRelationKind >> printOn: aStream [

	aStream nextPutAll: name
]
