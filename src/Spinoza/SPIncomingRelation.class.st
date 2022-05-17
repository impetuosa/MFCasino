Class {
	#name : #SPIncomingRelation,
	#superclass : #SPRelation,
	#instVars : [
		'from'
	],
	#category : #Spinoza
}

{ #category : #accessing }
SPIncomingRelation >> from [
	^ from
]

{ #category : #initialization }
SPIncomingRelation >> initialize [

	super initialize.
	from := Set new
]

{ #category : #initialization }
SPIncomingRelation >> printOn: aStream [

	aStream
		nextPutAll: (' | ' join: (from collect: [ :a | a name ]));
		nextPutAll: ' ';
		nextPutAll: kind name
]
