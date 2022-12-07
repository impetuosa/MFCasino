Class {
	#name : #SPCompareLogs,
	#superclass : #SPExperiment,
	#instVars : [
		'info',
		'logs'
	],
	#category : #Spinoza
}

{ #category : #initialization }
SPCompareLogs >> aggregationFor: model and: ontology [

	^ (info at: model ifAbsentPut: [ 
		   Dictionary new
			   at: #name put: model;
			   yourself ]) at: ontology ifAbsentPut: [ 
		  Dictionary new
			  at: #name put: ontology;
			  yourself ]
]

{ #category : #initialization }
SPCompareLogs >> ensure: success and: failures [

	self assert:
		(failures basename copyReplaceAll: '.txt' with: '.success.txt')
		= success basename
]

{ #category : #accessing }
SPCompareLogs >> info [
	^ info
]

{ #category : #initialization }
SPCompareLogs >> initialize [

	super initialize.
	logs := ('logs' asFileReference entries collect: #asFileReference) 
		        sort: #basename asSortFunction.
	info := Dictionary new .
]

{ #category : #initialization }
SPCompareLogs >> process [

	logs pairsDo: [ :success :failures | 
		self process: success and: failures ]
]

{ #category : #initialization }
SPCompareLogs >> process: success and: failures [

	| model ontology aggregation |
	self ensure: success and: failures.

	model := '-' split: failures basenameWithoutExtension.
	ontology := model second.
	model := model first.

	aggregation := self aggregationFor: model and: ontology.


	self processSuccess: success into: aggregation.
	self processFailures: failures into: aggregation
]

{ #category : #initialization }
SPCompareLogs >> processFailures: failures into: aggregation [
	| stream line |
	
	stream := failures readStream. 
	
	stream upToAll: OSPlatform current lineEnding. 
	aggregation at: #failures put: 0. 
	aggregation at: #'Type does not exist' put: 0.
	aggregation at: #'Typing Error' put: 0.
	aggregation at: #'Type does not have attribute' put: 0.
	
	
	[  stream atEnd ] whileFalse: [ 
		line := stream upToAll: OSPlatform current lineEnding.
		aggregation at: #failures put: (aggregation at: #failures) +1 . 
		
		(line includesSubstring:' cannot be represented ' caseSensitive: false ) ifTrue: [
			aggregation at: #'Type does not exist' put: (aggregation at: #'Type does not exist') +1 .
		].
		(line includesSubstring:' expected ' caseSensitive: false ) ifTrue: [
			aggregation at: #'Typing Error' put: (aggregation at: #'Typing Error') +1 .
		].
		(line includesSubstring:' any relation ' caseSensitive: false ) ifTrue: [
			aggregation at: #'Type does not have attribute' put: (aggregation at: #'Type does not have attribute') +1 .
		]
	].
	stream close .
	
		
]

{ #category : #initialization }
SPCompareLogs >> processSuccess: success into: aggregation [
	| stream count |
	
	stream := success readStream. 
	
	stream upToAll: OSPlatform current lineEnding. 
	count := 0. 
	[  stream atEnd ] whileFalse: [ 
		count := count + 1 .
		stream upToAll: OSPlatform current lineEnding.
	].
	aggregation at: #success put: count. 
	stream close. 
		
]
