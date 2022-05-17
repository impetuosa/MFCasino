Class {
	#name : #SPRelation,
	#superclass : #Object,
	#instVars : [
		'kind',
		'name',
		'cardinality'
	],
	#category : #Spinoza
}

{ #category : #accessing }
SPRelation >> cardinality [

	^ cardinality
]

{ #category : #accessing }
SPRelation >> cardinality: aString [
	aString = nil ifTrue: [ self halt. ].
	cardinality := aString 
]

{ #category : #accessing }
SPRelation >> kind [
	^ kind
]

{ #category : #accessing }
SPRelation >> kind: aSPRelationKind [ 
	kind := aSPRelationKind
]

{ #category : #accessing }
SPRelation >> name [
	^ name
]

{ #category : #accessing }
SPRelation >> name: aString [ 
	name := aString
]
