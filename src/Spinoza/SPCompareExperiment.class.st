Class {
	#name : #SPCompareExperiment,
	#superclass : #SPExperiment,
	#instVars : [
		'model',
		'ontology',
		'logStream'
	],
	#category : #Spinoza
}

{ #category : #'as yet unclassified' }
SPCompareExperiment class >> compare: aModelFileReference with: anOntologyFileReference [

	^ self
		  compare: aModelFileReference
		  with: anOntologyFileReference
		  streamingOn: Stdio stdout
]

{ #category : #'as yet unclassified' }
SPCompareExperiment class >> compare: aModelFileReference with: anOntologyFileReference logging: aFilePath [

	^ self
		  compare: aModelFileReference
		  with: anOntologyFileReference
		  streamingOn: aFilePath asFileReference writeStream
]

{ #category : #'as yet unclassified' }
SPCompareExperiment class >> compare: aModelFileReference with: anOntologyFileReference streamingOn: aStream [

	^ self new
		  logStream: aStream;
		  compare: aModelFileReference asFileReference
		  with: anOntologyFileReference asFileReference
]

{ #category : #verification }
SPCompareExperiment >> can: entity use: value with: slot [

	[ ^ ontology can: entity use: value with: slot ]
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
SPCompareExperiment >> logEntity: anEntity slot: slot text: aText [
	self haltIf: (aText includesSubstring: 'Instances of UndefinedObject are not indexable') .
	self logStream
		nextPutAll: anEntity className;
		nextPutAll: ';';
		nextPutAll: ((anEntity respondsTo: #name)
				 ifTrue: [ anEntity name ifNil: [ anEntity className ]]
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

	self haltIf: (aText includesSubstring:
			 'Instances of UndefinedObject are not indexable').
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

	"
		ontology typeFor: entity.
	entity class allSlots do: [ :s | 
		ontology can: entity use: (s read: entity) with: s ].
	"

	[ 
	self typeFor: entity.
	entity class allSlots do: [ :s | 
		[ self can: entity use: (s read: entity) with: s ]
			on: Error
			do: [ :e | self logEntity: entity slot: s text: e messageText ] ] ]
		on: Error
		do: [ :e | self logEntity: entity text: e messageText ]
]

{ #category : #verification }
SPCompareExperiment >> processModel [

	model entities do: [ :entity | self processEntity: entity ].
	logStream close
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
