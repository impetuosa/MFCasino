Class {
	#name : #SPOutgoingRelation,
	#superclass : #SPRelation,
	#category : #Spinoza
}

{ #category : #visiting }
SPOutgoingRelation >> acceptInstance: anOtherObject ontology: ontology [

	(anOtherObject isNil or: [ 
		 self isToMany and: [ 
			 anOtherObject isCollection and: [ anOtherObject isEmpty ] ] ]) 
		ifTrue: [ ^ true ].

	name = #parent ifTrue: [ ^ true ].

	^ (self isToMany and: [ anOtherObject isCollection ])
		  ifTrue: [ 
			  (anOtherObject allSatisfy: [ :o | 
				   to anySatisfy: [ :type | 
					   [ type acceptInstance: o ontology: ontology ]
						   on: Error
						   do: [ false ] ] ]) or: [ 
				  to anySatisfy: [ :type | 
					  [ type acceptInstance: anOtherObject ontology: ontology ]
						  on: Error
						  do: [ false ] ] ] ]
		  ifFalse: [ 
			  to anySatisfy: [ :type | 
				  [ type acceptInstance: anOtherObject ontology: ontology ]
					  on: Error
					  do: [ false ] ] ]
]

{ #category : #visiting }
SPOutgoingRelation >> acceptInstanceOrError: anOtherObject ontology: ontology [

	| return types |
	(anOtherObject isNil or: [ 
		 self isToMany and: [ 
			 anOtherObject isCollection and: [ anOtherObject isEmpty ] ] ]) 
		ifTrue: [ ^ true ].

	types := ontology typesFor: anOtherObject.

	name = #parent ifTrue: [ ^ true ].
	return := self isToMany
		          ifTrue: [ 
			          anOtherObject isCollection ifFalse: [ ^ false ].
			          (anOtherObject allSatisfy: [ :o | 
				           to anySatisfy: [ :type | 
					           [ type acceptInstance: o ontology: ontology ]
						           on: Error
						           do: [ false ] ] ]) or: [ 
				          to anySatisfy: [ :type | 
					          [ 
					          type acceptInstance: anOtherObject ontology: ontology ]
						          on: Error
						          do: [ false ] ] ] ]
		          ifFalse: [ 
			          to anySatisfy: [ :type | 
				          [ type acceptInstance: anOtherObject ontology: ontology ]
					          on: Error
					          do: [ false ] ] ].
	return ifTrue: [ ^ true ].

	types ifEmpty: [ 
		self error: ('Object of Type {1} cannot be represented ' format:
				 { anOtherObject className }) ].

	self error: ('{1} {2} expected {3}, got {4} instead. ' format: { 
				 from name.
				 name.
				 (' | ' join: (to collect: [ :a | a name ])).
				 (' | ' join: (types collect: [ :a | a name ])) })
]

{ #category : #'as yet unclassified' }
SPOutgoingRelation >> commonUsefulTo [

	| ret |
	self kind isKindOf ifTrue: [ ^ to ].
	to size > 1 ifFalse: [ ^ to ].

	ret := (to groupedBy: [ :a | a parents ]) size = 1
		       ifTrue: [ { to anyOne parents anyOne } asSet ]
		       ifFalse: [ 
		       (to collect: [ :t | t lastMeanignfulParent ]) asSet ].

	ret removeAllFoundIn: (from parent allCommonUsefulToAs: self).
	^ ret
]

{ #category : #'as yet unclassified' }
SPOutgoingRelation >> commonUsefulTo2 [

	| ret |
	self kind isKindOf ifTrue: [ ^ to ].
	to size > 1 ifFalse: [ ^ to ].

	ret := (to groupedBy: [ :a | a parents ]) size = 1
		       ifTrue: [ { to anyOne parents anyOne } ]
		       ifFalse: [ 
		       (to collect: [ :t | t lastMeanignfulParent ]) asSet ].
	^ ret
]

{ #category : #accessing }
SPOutgoingRelation >> from: aSPClass [

	from := aSPClass
]

{ #category : #accessing }
SPOutgoingRelation >> isOutgoing [

	^ true
]

{ #category : #accessing }
SPOutgoingRelation >> printOn: aStream [

	aStream
		nextPutAll: name ;
		nextPutAll: '- OUT ';
		nextPutAll: kind name;
		nextPutAll: ' ';
		nextPutAll: (' | ' join: (to collect: [ :a | a name ]))
]
