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

{ #category : #verification }
SPCompareExperiment >> compare: aModelFileReference with: anOntologyFileReference [

	model := self loadModel: aModelFileReference.
	ontology := self loadOntology: anOntologyFileReference.
	model language useOntologicalConstraintWith: ontology.
	model entities do: [ :entity | 
		[ 
		ontology typeFor: entity.
		entity allSlots do: [ :s | 
			[ ontology can: entity use: (s read: entity) with: s ]
				on: Error
				do: [ :e | self logEntity: entity slot: s text: e messageText ] ] ]
			on: Error
			do: [ :e | self logEntity: entity text: e messageText ] ].
	logStream close
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

	self logStream
		nextPutAll: anEntity;
		nextPutAll: ';';
		nextPutAll: slot name;
		nextPutAll: ';';
		nextPutAll: (slot isMany
				 ifTrue: [ 'many' ]
				 ifFalse: [ 'one' ]);
		nextPutAll: ';';
		nextPutAll: aText;
		newLine
]

{ #category : #verification }
SPCompareExperiment >> logEntity: anEntity text: aText [

	self logStream
		nextPutAll: anEntity;
		nextPutAll: ';';
		nextPutAll: 'N\A';
		nextPutAll: ';';
		nextPutAll: 'N\A';
		nextPutAll: ';';
		nextPutAll: aText;
		newLine
]

{ #category : #verification }
SPCompareExperiment >> logStream [

	^ logStream ifNil: [ 
		  logStream := 'compare.log' asFileReference writeStream ]
]
