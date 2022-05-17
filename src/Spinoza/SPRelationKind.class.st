Class {
	#name : #SPRelationKind,
	#superclass : #Object,
	#instVars : [
		'name'
	],
	#category : #Spinoza
}

{ #category : #accessing }
SPRelationKind >> name [
	^ name
]

{ #category : #accessing }
SPRelationKind >> name: aString [ 
	name := aString
]
