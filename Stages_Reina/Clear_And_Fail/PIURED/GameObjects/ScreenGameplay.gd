extends Node2D
# Once you realize that documentation should be laughed at, peed upon, put on fire, 
# and just ridiculed in general, THEN, and only then, have you reached the level where
# you can safely read it and try to use it to actually implement a driver. 
# - Linus Torvalds

# General structure:
# ScreenGameplay: This is the base object. It configures everything.
# - Song: It holds the song. Well, kind of. It also holds the steps because data structures are hard.
#   - [Step 1, Step 2, etc]: A bunch of Steps objects
# - PlayerStage
#   - BeatManager (Manages timing for the notes)
#   - Receptors
#   - Notefield: Handles moving the notes, also checks inputs.
#     - Notes: These don't do anything on their own, they're just Node2Ds that contain note information.

#/*
# * # Copyright (C) Pedro G. Bascoy
# # This file is part of piured-engine <https://github.com/piulin/piured-engine>.
# #
# # piured-engine is free software: you can redistribute it and/or modify
# # it under the terms of the GNU General Public License as published by
# # the Free Software Foundation, either version 3 of the License, or
# # (at your option) any later version.
# #
# # piured-engine is distributed in the hope that it will be useful,
# # but WITHOUT ANY WARRANTY; without even the implied warranty of
# # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# # GNU General Public License for more details.
# #
# # You should have received a copy of the GNU General Public License
# # along with piured-engine.If not, see <http://www.gnu.org/licenses/>.
# *
# */

export(String) var songToLoad = "Gargoyle"
export(int) var levelToLoad = 0
export(float,0.15,2) var accuracyMargin=0.15


var animationRate:int=30
var playerStages:Array=[]
onready var song=$Song
#Debugging func to set up ScreenGameplay
# /**
# * Constructs the stage where one or more players will dance. In a nutshell, the stage sets up the environment needed
# * to play a specific tune associated with its Stepmania step definition file (i.e., mp3+SSC).
# * This method must be called before adding new players to the stage through {@link Engine#addPlayer}.
# * @param {StageConfig} stageConfig stage configuration
# * @return {undefined}
# *
# * @example <caption> Configuring a new stage. Details of the {@link StageConfig} object are omitted.</caption>
# * let stageConfig = new StageConfig( ... ) ;
# * engine.configureStage(stageConfig) ;
# */

func get_matching_files_extensions(path,fname):
	#var files = []
	var dir = Directory.new()
	print("Opening "+path)
	var ok = dir.open(path)
	if ok != OK:
		printerr("Warning: could not open directory: ERROR ", ok)
		return null
	#print(dir.get_current_dir())
	dir.list_dir_begin(false,true)

	while true:
		var file = dir.get_next()
		print(file)
		if file == "":
			dir.list_dir_end()
			return null
		elif file.ends_with(fname):
			print("Found file:"+file)
			#print("Return "+path+file)
			dir.list_dir_end()
			return path+file

func _ready():
	print("ScreenGameplay START!")

	

func init():
	#var files = 
	
	var sscPath:String = songToLoad
	if !("/" in songToLoad):
		sscPath = get_matching_files_extensions("res://Stages_Reina/Clear_And_Fail/Songs/"+songToLoad+"/",".ssc")


	#func constructor( pathToSSCFile:String, audioFilePath:String, offset, playBackSpeed, onReadyToStart ):
	#song.constructor()
	song.constructor(sscPath,.100,1)
	
	$VBoxContainer.visible=false
	$VBoxContainer/Button.disabled=true
	
	print("Finish loading Song class, now set up player.")
	addPlayerStage({
		inputConfig=null,
		noteskin="Prime",
		level=levelToLoad,
		speed=1.0,
		accuracyMargin = accuracyMargin,
		receptorX = 0,
		receptorY = 0,
		scale = 1.0
	})
	print("Game is ready to start, telling ScreenGameplay to start playing music and telling the players to start processing")
	var start = OS.get_ticks_msec()

	song.startPlayBack(start)
	$PlayerStage.beatManager.requiresResync=true
	pass

# This function seems to get the scores?
#retrievePerformancePlayerStages() {
#	let performances = [] ;
#	for (let i = 0 ; i < self._playerStages.length ; i++) {
#		performances.push( self._playerStages[i].judgment.performance ) ;
#	}
#	return performances ;
#}

#configureNoteTextures(noteskin) {
#	new StepNoteTexture(self._resourceManager, 'dl', self.animationRate, noteskin) ;
#	new StepNoteTexture(self._resourceManager, 'ul', self.animationRate, noteskin) ;
#	new StepNoteTexture(self._resourceManager, 'c', self.animationRate, noteskin) ;
#	new StepNoteTexture(self._resourceManager, 'ur', self.animationRate, noteskin) ;
#	new StepNoteTexture(self._resourceManager, 'dr', self.animationRate, noteskin) ;
#
#	new HoldExtensibleTexture(self._resourceManager, 'dl', self.animationRate, noteskin) ;
#	new HoldExtensibleTexture(self._resourceManager, 'ul', self.animationRate, noteskin) ;
#	new HoldExtensibleTexture(self._resourceManager, 'c', self.animationRate, noteskin) ;
#	new HoldExtensibleTexture(self._resourceManager, 'ur', self.animationRate, noteskin) ;
#	new HoldExtensibleTexture(self._resourceManager, 'dr', self.animationRate, noteskin) ;
#}
#
#configureBG() {
#
#	self._bg = new Background(self._resourceManager, self._playerStages[0].beatManager) ;
#	self._bg.object.position.y = -3 ;
#	self._bg.object.position.z = -1 ;
#	self._object.add(self._bg.object) ;
#
#}


#Adds a player stage, then returns the index of the stage (starting from 0.)
func addPlayerStage( playerConfig:Dictionary, playBackSpeed:float=1.0 )->int:

	var lifebarOrientation:String ;

	if ( self.playerStages.size() % 2 == 0 ):
		lifebarOrientation = 'left2right' ;
	else:
		lifebarOrientation = 'right2left' ;
	

	var stage = $PlayerStage

	stage.constructor(self.song,
		playerConfig,
		playBackSpeed,
		self.playerStages.size(),
		lifebarOrientation) ;

	#stage.setScale(playerConfig.scale) ;

	self.playerStages.append(stage) ;
	self.adjustPlayerStages() ;
	print("Add new playerStage! Now "+String(playerStages.size())+" player are loaded.")

	#// We can only configure the background if we have at least one stage (beat manager) set up.
	# if ( self._playerStages.length == 1 )  {
	# 	self.configureBG() ;
	# }

	# stageID
	return self.playerStages.size() -1 ;

# func logFrame(playerStageId, json) {
# 	self._playerStages[playerStageId].logFrame(json) ;
# }

func adjustPlayerStages():
	
# 	var no_stages = self._playerStages.size() ;


# 	let distance = 0 ;
# 	if (no_stages === 2 ) {
# 		distance = 7 ;
# 	} else  {
# 		distance = 5 ;
# 	}

# 	for (let i = 0 ; i < no_stages ; i++ ) {
# 		if (  self.song.getStepsType(self._playerStages[i]._level) === 'pump-double' || self.song.getStepsType(self._playerStages[i]._level) === 'pump-halfdouble' ) {
# 			distance = 9 ;
# 			break ;
# 		}
# 	}


# 	let Xpos = -(distance*no_stages)/2 + distance/2;

# 	for (let i = 0 ; i < no_stages ; i++ ) {
# 		self._playerStages[i].object.position.x = Xpos + self._playerStages[i].playerConfig.receptorX ;
# 		self._playerStages[i].object.position.y = self._playerStages[i].playerConfig.receptorY ;
# 		Xpos += distance ;
# 	}

# }
	print("adjustPlayerStage() stub!")
	pass

func setNewPlayBackSpeed ( newPlayBackSpeed:float ):
	print("setNewPlayBackSpeed() stub!")
	#for i in range(_playerStages.size()):
	#	self._playerStages[i].setNewPlayBackSpeed ( newPlayBackSpeed ) ;
	pass


func updateOffset(stageId:int, newOffsetOffset:float):
	self._playerStages[stageId].beatManager.updateOffset(newOffsetOffset) ;


func _input(event):
	if Input.is_action_just_pressed("ui_pause"):
		get_tree().change_scene("res://Stages_Reina/Clear_And_Fail/PIURED_DebugTest.tscn")

#If Android back button pressed
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene("res://Stages_Reina/Clear_And_Fail/PIURED_DebugTest.tscn")
