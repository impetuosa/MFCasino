Class {
	#name : #SPCompareExperiment,
	#superclass : #SPExperiment,
	#instVars : [
		'model',
		'ontology',
		'logStream',
		'successStream'
	],
	#category : #Spinoza
}

{ #category : #'as yet unclassified' }
SPCompareExperiment class >> compare: aModelFileReference with: anOntologyFileReference logging: aFilePath [

	^ self
		  compare: aModelFileReference
		  with: anOntologyFileReference
		  streamingOn: aFilePath asFileReference writeStream
		  successOn:
			  (aFilePath copyReplaceAll: '.txt' with: '.success.txt')
				  asFileReference writeStream
]

{ #category : #'as yet unclassified' }
SPCompareExperiment class >> compare: aModelFileReference with: anOntologyFileReference streamingOn: aStream successOn: anOtherStream [

	^ self new
		  logStream: aStream;
		  logSuccessStream: anOtherStream;
		  compare: aModelFileReference asFileReference
		  with: anOntologyFileReference asFileReference
]

{ #category : #verification }
SPCompareExperiment >> can: entity use: value with: slot [

	| val |
	
	[ 
	val := ontology can: entity use: value with: slot.
	self haltIf: ({ 
			 True.
			 False } includes: val class) not.
	^ val ]
		on: MessageNotUnderstood
		do: [ :m | self halt ]
]

{ #category : #verification }
SPCompareExperiment >> compare: aModelFileReference with: anOntologyFileReference [

	ontology := self loadOntology: anOntologyFileReference.
	model := self loadModel: aModelFileReference.

	self processModel. 
]

{ #category : #verification }
SPCompareExperiment >> loadModel: aPath [

	^ MOModel loadFrom: aPath
]

{ #category : #verification }
SPCompareExperiment >> loadOntology: aPath [

	^ SPOntology loadFrom: aPath
]

{ #category : #verification }
SPCompareExperiment >> logAcceptedEntity: entity val: val slot: s [

	| estr vstr sstr |
	
	[ 
	[ estr := entity asString ]
		on: Error
		do: [ estr := entity className ].
	[ vstr := val asString ]
		on: Error
		do: [ vstr := val className ].
	[ sstr := s asString ]
		on: Error
		do: [ sstr := s className ].
	successStream
		nextPutAll: estr;
		nextPutAll: ';';
		nextPutAll: vstr;
		nextPutAll: ';';
		nextPutAll: sstr;
		nextPutAll: OSPlatform current lineEnding ]
		on: Error
		do: [ :e | self halt ]
]

{ #category : #verification }
SPCompareExperiment >> logEntity: anEntity slot: slot text: aText [

	self logStream
		nextPutAll: anEntity className;
		nextPutAll: ';';
		nextPutAll: ((anEntity respondsTo: #name)
				 ifTrue: [ anEntity name ifNil: [ anEntity className ] ]
				 ifFalse: [ 'N\A' ]);
		nextPutAll: ';';
		nextPutAll: slot name;
		nextPutAll: ';';
		nextPutAll: (slot isToMany
				 ifTrue: [ 'many' ]
				 ifFalse: [ 'one' ]);
		nextPutAll: ';';
		nextPutAll: aText;
		nextPutAll: OSPlatform current lineEnding
]

{ #category : #verification }
SPCompareExperiment >> logEntity: anEntity text: aText [

	self logStream
		nextPutAll: anEntity className;
		nextPutAll: ';';
		nextPutAll: ((anEntity respondsTo: #name)
				 ifTrue: [ anEntity name ifNil: [ 'N\A' ] ]
				 ifFalse: [ 'N\A' ]);
		nextPutAll: ';';
		nextPutAll: 'N\A';
		nextPutAll: ';';
		nextPutAll: 'N\A';
		nextPutAll: ';';
		nextPutAll: aText;
		nextPutAll: OSPlatform current lineEnding
]

{ #category : #verification }
SPCompareExperiment >> logStream [

	^ logStream ifNil: [ 
		  self logStream: 'compare.log' asFileReference writeStream.
		  logStream ]
]

{ #category : #verification }
SPCompareExperiment >> logStream: aStream [

	logStream := aStream.

	aStream
		nextPutAll: 'ClassName;Name;SlotName;Cardinality;Error';
		nextPutAll:  OSPlatform current lineEnding
]

{ #category : #verification }
SPCompareExperiment >> logSuccessStream: aStream [

	successStream := aStream.
	aStream
		nextPutAll: 'Entity;Value;Slot';
		nextPutAll: OSPlatform current lineEnding
]

{ #category : #accessing }
SPCompareExperiment >> model: aMOModel [ 
	model := aMOModel
]

{ #category : #accessing }
SPCompareExperiment >> ontology: aSPOntology [ 
	ontology := aSPOntology
]

{ #category : #verification }
SPCompareExperiment >> processEntity: entity [

	| val s relations |
	"
		ontology typeFor: entity.
	entity class allSlots do: [ :s | 
		ontology can: entity use: (s read: entity) with: s ].
	"
	[ 
	relations := entity allOntologicalRelations.
	self typeFor: entity.
	relations do: [ :relation | 
		[ 
		val := relation to.
		s := relation slot.
		(self can: entity use: val with: s) ifTrue: [ 
			self logAcceptedEntity: entity val: val slot: s ] 
		]
			on: Error
			do: [ :e | self logEntity: entity slot: s text: e messageText ] ] ]
		on: Error
		do: [ :e | 
			self logEntity: entity text: e messageText.
			relations do: [ :relation | 
				self
					logEntity: entity
					slot: relation slot
					text:
						('Object of Type {1} does not register any relation {2} of kind {3} ' 
							 format: { 
									 relation from className.
									 relation slot name.
									 relation slot className }) ] ]
]

{ #category : #verification }
SPCompareExperiment >> processModel [

	model entities do: [ :entity | self processEntity: entity ].
	logStream close
]

{ #category : #verification }
SPCompareExperiment >> successStream [

	^ successStream
]

{ #category : #verification }
SPCompareExperiment >> typeFor: entity [

	[ 
	[ ^ ontology typeFor: entity ]
		on: MessageNotUnderstood
		do: [ :e | self halt ] ]
		on: NotFound
		do: [ :error | 
			self error: ('Object of Type {1} cannot be represented ' format:
					 { entity className }) ]
]
