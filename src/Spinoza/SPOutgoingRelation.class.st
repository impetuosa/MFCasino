Class {
	#name : #SPOutgoingRelation,
	#superclass : #SPRelation,
	#instVars : [
		'to'
	],
	#category : #Spinoza
}

{ #category : #initialization }
SPOutgoingRelation >> initialize [

	super initialize.
	to := Set new
]

{ #category : #accessing }
SPOutgoingRelation >> printOn: aStream [

	aStream
		nextPutAll: kind name;
		nextPutAll: ' ';
		nextPutAll: (' | ' join: (to collect: [ :a | a name ]))
]

{ #category : #accessing }
SPOutgoingRelation >> to [
	^ to
]
