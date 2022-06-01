Class {
	#name : #SPOntologyExtractor,
	#superclass : #Object,
	#instVars : [
		'classes',
		'classUsageCounter',
		'relationKinds',
		'relations',
		'traversed',
		'queue',
		'tracker'
	],
	#classInstVars : [
		'extracted'
	],
	#category : #Spinoza
}

{ #category : #'as yet unclassified' }
SPOntologyExtractor class >> extractFor: aModel [

	^SPOntologyExtractor new extractFromModel: aModel
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor class >> extracted [

	^ extracted ifNil: [ extracted := Dictionary new ]
]

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

{ #category : #accessing }
SPOntologyExtractor >> classes [
	^ classes values 
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor >> extractFromModel: aMOModel [
	self halt .
	self
		relate: aMOModel
		with: aMOModel root
		kind: #'Has A'
		name: #Root
		cardinality: #one.

	self processNode: aMOModel root.

	[ queue isEmpty ] whileFalse: [ self processNode: queue removeFirst ]
	.
	self processProperties.

	^ SPOntology new
		  classes: classes;
		  relations: relations;
		  name: aMOModel name;
		  yourself
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor >> initialize [

	super initialize.
	classes := Dictionary new.
	classUsageCounter := Dictionary new.
	relationKinds := Dictionary new.
	relations := OrderedCollection new.
	traversed := OrderedCollection new.
	queue := OrderedCollection new.
	tracker := Dictionary new.
]

{ #category : #accessing }
SPOntologyExtractor >> model [

	^ classes values detect: [ :a | a name = #MOModel ]
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
	anObject isCollection ifTrue: [ 
		^ anObject do: [ :a | self processNode: a ] ].
	(anObject allRelations groupedBy: #relationName) do: [ :rel | 
		self processRelations: rel ]
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor >> processProperties [
	tracker keysAndValuesDo: [ :key :val | 
		val keysAndValuesDo: [ :classTo :valuesSample | 
			(self
				 resolvePropertyTo: classTo
				 sampled: valuesSample
				 relationNamed: key third) do: [ :realClass | 
				self
					relateClass: key first
					withClass: realClass
					kind: #'Is Described by ' , (key second
							 ifTrue: [ #Many ]
							 ifFalse: [ #One ])
					name: key third
					cardinality: (key second
							 ifTrue: [ #Many ]
							 ifFalse: [ #One ]) ] ] ]
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor >> processRelations: aCollection [

	aCollection do: [ :r | r acceptVisitor: self ]
]

{ #category : #visiting }
SPOntologyExtractor >> queueUp: anObj [

	anObj ifNil: [ ^ self ].
	self assert: anObj isMOObject.
	anObj isCollection
		ifTrue: [ queue addAll: anObj ]
		ifFalse: [ queue add: anObj ]
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
			            relation from: aDeclaration.
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
			            relation to: anOtherDeclaration.
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

{ #category : #accessing }
SPOntologyExtractor >> resolvePropertyTo: aSPClass sampled: aCollection relationNamed: aRelationName [

	| packageName |
	packageName := (self class environment at: aSPClass name) package
		               name.
	(packageName beginsWith: #Moxing) ifTrue: [ ^ { aSPClass } ].
	aCollection size > 10 ifFalse: [ ^ { aSPClass } ].
	(aCollection asSet size / aCollection size) asFloat < 0.05 ifFalse: [ 
		^ { aSPClass } ].
	"self halt: aCollection asSet asString."
	^ aCollection asSet collect: [ :a | 
		  ((self
			    subclassOf: aSPClass
			    named: a asString capitalized
			    relationNamed: aRelationName) outgoingRelations detect: [ :or | 
			   or kind name = 'Is A' ]) to anyOne ]
]

{ #category : #'as yet unclassified' }
SPOntologyExtractor >> subclassOf: aClass named: aName [

	| class superClass |

	class := classes at: (aName, aClass name)  ifAbsentPut: [ 
		         class := SPClass new name: aName capitalized.
		         superClass := aClass.
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
SPOntologyExtractor >> subclassOf: aClass named: aName relationNamed: aRelationName [

	| class superClass |
	class := classes at: aName , aClass name ifAbsentPut: [ 
		         class := SPClass new name: aName capitalized.
		         superClass := self
			                       subclassOf: self thing
			                       named: aRelationName.
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
		kind: #'Defines ' , (aMODeclarationStructuralRelation isToMany
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

	| from to set col isMany |
	isMany := false.
	aMODeclarationStructuralRelation to ifNil: [ ^ self ].
	(aMODeclarationStructuralRelation to isCollection and: [ 
		 aMODeclarationStructuralRelation to isString not ]) ifTrue: [ 
		aMODeclarationStructuralRelation to
			ifEmpty: [ ^ self ]
			ifNotEmpty: [ isMany := true ] ].

	from := self classFor: aMODeclarationStructuralRelation from.
	to := self classFor: aMODeclarationStructuralRelation to.

	set := tracker
		       at: { 
				       from.
				       (aMODeclarationStructuralRelation isToMany or: [ isMany ]).
				       aMODeclarationStructuralRelation relationName }
		       ifAbsentPut: [ Dictionary new ].
	col := set at: to ifAbsentPut: [ OrderedCollection new ].

	(aMODeclarationStructuralRelation to isCollection and: [ 
		 aMODeclarationStructuralRelation to isString not ])
		ifTrue: [ 
			(#( indexes modifiers metadata) includes:
				 aMODeclarationStructuralRelation relationName) ifFalse: [ 
				self halt ].
			col addAll: aMODeclarationStructuralRelation to ]
		ifFalse: [ col add: aMODeclarationStructuralRelation to ]
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
