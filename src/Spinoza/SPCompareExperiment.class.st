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

	| entities |
	model := self loadModel: aModelFileReference.
	ontology := self loadOntology: anOntologyFileReference.
	model language useOntologicalConstraintWith: ontology.
	entities := model incorrectEntities.
	entities do: [ :e | self logEntity: e ].

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
SPCompareExperiment >> logEntity: anEntity [

	self logStream nextPutAll: ''
]

{ #category : #verification }
SPCompareExperiment >> logStream [

	^ logStream ifNil: [ 
		  logStream := 'compare.log' asFileReference writeStream ]
]
