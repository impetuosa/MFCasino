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
		(failures basename copyReplaceAll: '.txt' with: '.relations.txt')
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

	logs pairsDo: [ :relations :typings | 
		self process: relations and: typings ]
]

{ #category : #initialization }
SPCompareLogs >> process: relations and: typings [

	| model ontology aggregation |

	self ensure: relations and: typings.

	model := '-' split: typings basenameWithoutExtension.
	ontology := model second.
	model := model first.

	aggregation := self aggregationFor: model and: ontology.


	self processTypings: typings  into: aggregation.
	self processRelations: relations into: aggregation
]

{ #category : #initialization }
SPCompareLogs >> processRelations: failures into: aggregation [

	| stream line |
	stream := failures readStream.

	stream upToAll: OSPlatform current lineEnding.
	aggregation at: #AcceptedRelations put: 0.
	aggregation at: #RejectedRelations put: 0.


	[ stream atEnd ] whileFalse: [ 
		line := stream upToAll: OSPlatform current lineEnding.
		(line endsWith: ';A' caseSensitive: false)
			ifTrue: [ 
				aggregation
					at: #AcceptedRelations
					put: (aggregation at: #AcceptedRelations) + 1 ]
			ifFalse: [ 
				(line endsWith: ';R' caseSensitive: false)
					ifTrue: [ 
						aggregation
							at: #RejectedRelations
							put: (aggregation at: #RejectedRelations) + 1 ]
					ifFalse: [ self error: 'Cannot process this ' ] ] ].
	stream close
]

{ #category : #initialization }
SPCompareLogs >> processTypings: failures into: aggregation [

	| stream line |
	stream := failures readStream.

	stream upToAll: OSPlatform current lineEnding.
	aggregation at: #AcceptedEntity put: 0.
	aggregation at: #RejectedEntity put: 0.


	[ stream atEnd ] whileFalse: [ 
		line := stream upToAll: OSPlatform current lineEnding.
		(line endsWith: ';A' caseSensitive: false)
			ifTrue: [ 
				aggregation
					at: #AcceptedEntity
					put: (aggregation at: #AcceptedEntity) + 1 ]
			ifFalse: [ 
				(line endsWith: ';R' caseSensitive: false)
					ifTrue: [ 
						aggregation
							at: #RejectedEntity
							put: (aggregation at: #RejectedEntity) + 1 ]
					ifFalse: [ self error: 'Cannot process this ' ] ] ].
	stream close
]
