Class {
	#name : #SPOntologyExtractor,
	#superclass : #Object,
	#instVars : [
		'classes',
		'classUsageCounter',
		'relationKinds',
		'relations',
		'traversed',
		'queue'
	],
	#category : #Spinoza
}

{ #category : #public }
SPOntologyExtractor >> classFor: anObject [

	anObject ifNil: [ ^ self thing ].
	^ self classForClass: anObject class
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor >> classForClass: aClass [

	| class superClass |
	({ 
		 Object.
		 ProtoObject } includes: aClass) ifTrue: [ ^ self thing ].

	class := classes at: aClass ifAbsentPut: [ 
		         class := SPClass new name: aClass name.
		         superClass := self classForClass: aClass superclass.
		         self
			         relateClass: class
			         withClass: superClass
			         kind: #'Is A'
			         name: #'Kind Of'
			         cardinality: #one.
		         class ].
	classUsageCounter
		at: class
		put: (classUsageCounter at: class ifAbsent: [ 0 ]) + 1.
	^ class
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor >> extractFromModel: aMOModel [

	self
		relate: aMOModel
		with: aMOModel root
		kind: #'Has A'
		name: #Root
		cardinality: #one.

	self processNode: aMOModel root.

	[ queue isEmpty ] whileFalse: [ self processNode: queue removeFirst ].


	^ self
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor >> initialize [

	super initialize.
	classes := Dictionary new.
	classUsageCounter := Dictionary new.
	relationKinds := Dictionary new.
	relations := OrderedCollection new.
	traversed := OrderedCollection new.
	queue := OrderedCollection new
]

{ #category : #'instance creation' }
SPOntologyExtractor >> newIncomingRelationOfKind: aString [

	| rel |
	rel := SPIncomingRelation new
		       kind: (self relationKind: aString);
		       yourself.
	relations add: rel.
	^ rel
]

{ #category : #'instance creation' }
SPOntologyExtractor >> newOutgoingRelationOfKind: aString [

	| rel |
	rel := SPOutgoingRelation new
		       kind: (self relationKind: aString);
		       yourself.
	relations add: rel.
	^ rel
]

{ #category : #'equivalence classes' }
SPOntologyExtractor >> processNode: anObject [

	(traversed includes: anObject) ifTrue: [ ^ self ].
	anObject isNil ifTrue: [ ^ self ].
	traversed add: anObject.
	(anObject allRelations groupedBy: #relationName) do: [ :rel | 
		self processRelations: rel ]
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor >> processRelations: aCollection [

	aCollection do: [ :r | r acceptVisitor: self ]
]

{ #category : #visiting }
SPOntologyExtractor >> queueUp: anObj [

	queue add: anObj
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor >> relate: aDeclaration with: anOtherDeclaration kind: aString name: aName cardinality: oneOrMany [

	^ self
		  relateClass: (self classFor: aDeclaration)
		  withClass: (self classFor: anOtherDeclaration)
		  kind: aString
		  name: aName
		  cardinality: oneOrMany
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor >> relateClass: aDeclaration withClass: anOtherDeclaration kind: aString name: aName cardinality: oneOrMany [

	| relation |
	relation := aDeclaration outgoingRelations
		            detect: [ :a | 
		            a kind name = aString and: [ a name = aName ] ]
		            ifNone: [ 
			            relation := self newOutgoingRelationOfKind: aString.
			            relation name: aName.
			            relation cardinality: oneOrMany.
			            aDeclaration addOutgoingRelation: relation.
			            relation ].
	relation cardinality ifNil: [ relation cardinality: oneOrMany ].
	self assert: relation cardinality = oneOrMany.
	relation to add: anOtherDeclaration.
	relation := anOtherDeclaration incomingRelations
		            detect: [ :a | 
		            a kind name = aString and: [ a name = aName ] ]
		            ifNone: [ 
			            relation := self newIncomingRelationOfKind: aString.
			            relation name: aName.
			            anOtherDeclaration addIncomingRelation: relation.
			            relation ].
	relation cardinality ifNil: [ relation cardinality: oneOrMany ].
	self assert: relation cardinality = oneOrMany.
	relation from add: aDeclaration
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor >> relationKind: aString [

	^ relationKinds at: aString ifAbsentPut: [ 
		  SPRelationKind new
			  name: aString;
			  yourself ]
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor >> thing [

	^ classes at: Object ifAbsentPut: [ 
		  SPClass new
			  name: #Thing;
			  yourself ]
]

{ #category : #visiting }
SPOntologyExtractor >> visitCandidateRelation: aMODeclarationStructuralRelation [

	| from to |
	from := self classFor: aMODeclarationStructuralRelation from.
	to := self classFor: aMODeclarationStructuralRelation to.

	self
		relateClass: from
		withClass: to
		kind: #'Refers To ' , (aMODeclarationStructuralRelation isToMany
				 ifTrue: [ #Many ]
				 ifFalse: [ #One ])
		name: aMODeclarationStructuralRelation relationName
		cardinality: (aMODeclarationStructuralRelation isToMany
				 ifTrue: [ #many ]
				 ifFalse: [ #one ]).
	self queueUp: aMODeclarationStructuralRelation to
]

{ #category : #visiting }
SPOntologyExtractor >> visitContainmentRelation: aMODeclarationStructuralRelation [

	| from to |
	from := self classFor: aMODeclarationStructuralRelation from.
	to := self classFor: aMODeclarationStructuralRelation to.
	self
		relateClass: from
		withClass: to
		kind: #'Has ' , (aMODeclarationStructuralRelation isToMany
				 ifTrue: [ #Many ]
				 ifFalse: [ #A ])
		name: aMODeclarationStructuralRelation relationName
		cardinality: (aMODeclarationStructuralRelation isToMany
				 ifTrue: [ #many ]
				 ifFalse: [ #one ]).

	self queueUp: aMODeclarationStructuralRelation to
]

{ #category : #visiting }
SPOntologyExtractor >> visitExpressionRelation: aMODeclarationStructuralRelation [

	| from to |
	from := self classFor: aMODeclarationStructuralRelation from.
	to := self classFor: aMODeclarationStructuralRelation to.


	self
		relateClass: from
		withClass: to
		kind: #'Expresses ' , (aMODeclarationStructuralRelation isToMany
				 ifTrue: [ #Many ]
				 ifFalse: [ #One ])
		name: aMODeclarationStructuralRelation relationName
		cardinality: (aMODeclarationStructuralRelation isToMany
				 ifTrue: [ #many ]
				 ifFalse: [ #one ]).


	self queueUp: aMODeclarationStructuralRelation to
]

{ #category : #visiting }
SPOntologyExtractor >> visitPropertyRelation: aMODeclarationStructuralRelation [

	| from to |
	from := self classFor: aMODeclarationStructuralRelation from.
	to := self classFor: aMODeclarationStructuralRelation to.


	self
		relateClass: from
		withClass: to
		kind: #'Is Described by ' , (aMODeclarationStructuralRelation isToMany
				 ifTrue: [ #Many ]
				 ifFalse: [ #One ])
		name: aMODeclarationStructuralRelation relationName
		cardinality: (aMODeclarationStructuralRelation isToMany
				 ifTrue: [ #many ]
				 ifFalse: [ #one ])
]

{ #category : #visiting }
SPOntologyExtractor >> visitReferenceRelation: aMODeclarationStructuralRelation [

	| from to |
	from := self classFor: aMODeclarationStructuralRelation from.
	to := self classFor: aMODeclarationStructuralRelation to.

	self
		relateClass: from
		withClass: to
		kind: #'Refers To ' , (aMODeclarationStructuralRelation isToMany
				 ifTrue: [ #Many ]
				 ifFalse: [ #One ])
		name: aMODeclarationStructuralRelation relationName
		cardinality: (aMODeclarationStructuralRelation isToMany
				 ifTrue: [ #many ]
				 ifFalse: [ #one ])
]
