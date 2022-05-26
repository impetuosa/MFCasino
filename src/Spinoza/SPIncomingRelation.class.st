Class {
	#name : #SPIncomingRelation,
	#superclass : #SPRelation,
	#category : #Spinoza
}

{ #category : #initialization }
SPIncomingRelation >> printOn: aStream [

	aStream nextPutAll: 'IN ';
		nextPutAll: (' | ' join: (from collect: [ :a | a name ]));
		nextPutAll: ' ';
		nextPutAll: kind name
]

{ #category : #accessing }
SPIncomingRelation >> to: aSPClass [

	to := aSPClass
]
