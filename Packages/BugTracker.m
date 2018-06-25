(* ::Package:: *)

(* Autogenerated Package *)

FindBugsNotebook::usage=
	"Find the bugs notebook for a project";
NewBugsNotebook::usage=
	"Makes a new bugs notebook for a project";
BugsNotebookOpen::usage=
	"Opens a BugsTracker notebook";


BugsNotebookAdd::usage=
	"Adds a bug to a bugs notebook";
BugsNotebookLocate::usage=
	"Finds a bug in the bugs notebook";


BugsNotebookToBugs::usage=
	"Converts a bugs notebook to a list of bugs";


BugObject::usage=
	"An object representing a bug internally";
BugsToDataset::usage=
	"Converts a set of bugs to a Dataset for ease of searching";


PackageScopeBlock[
	BugsNotebookAddDataDialog::usage="Opens a dialog for getting bug data";
	BugsNotebookSearchBar::usage="Search bar for a bugs notebook";
	BugsCellToBug::usage=
	"Converts a cell to a bug";
	]


Begin["`Private`"];


(* ::Subsection:: *)
(*Bugs Notebooks*)



$BugsNotebookExtensions=
	{
		{"Testing", "Bugs"},
		{"Private", "Bugs"},
		{"Bugs"},
		{}
		}


(* ::Subsubsection::Closed:: *)
(*FindBugsNotebook*)



FindBugsNotebook[
	dir:(_String|_File)?DirectoryQ, 
	nbPattern:_?StringPattern`StringPatternQ:"BugTracker.nb"
	]:=
	Replace[
		FileNames[
			nbPattern,
			FileNameJoin@Prepend[#, dir]&/@$BugsNotebookExtensions
			],
		{
			{f_, ___}:>f,
			_->$Failed
			}
		]


(* ::Subsubsection::Closed:: *)
(*NewBugsNotebook*)



NewBugsNotebook[
	dir:(_String|_File)?DirectoryQ, 
	name:_?StringQ:"BugTracker.nb"
	]:=
	BugsNotebookOpen@
		Export[
			FileNameJoin@{dir, StringTrim[name, ".nb", IgnoreCase->True]<>".nb"},
			Notebook[
				{
					Cell[
						TextData@{"Bug Tracker", "  ", 
							Cell[
								BoxData@ToBoxes@
									BugsNotebookSearchBar[],
								"Text"
								]
							}, 
						"Chapter"
						]
					},
				StyleDefinitions->PackageFEFile["Private", "BugTracker.nb"]
				]
			]


(* ::Subsubsection::Closed:: *)
(*BugsNotebookOpen*)



ClearAll[BugsNotebookOpen];
Options[BugsNotebookOpen]=
	Options[NotebookOpen]
BugsNotebookOpen[
	nb:(_String|_File)?(FileExistsQ[#]&&!DirectoryQ[#]&),
	ops:OptionsPattern[]
	]:=
	NotebookOpen[nb, ops,
		StyleDefinitions->PackageFEFile["Private", "BugTracker.nb"]
		]
BugsNotebookOpen[
	dir:(_String|_File)?DirectoryQ, 
	nbPattern:_?StringPattern`StringPatternQ:"BugTracker.nb",
	ops:OptionsPattern[NotebookOpen]
	]:=
	Replace[FindBugsNotebook[dir, nbPattern, ops],
		{
			f_String:>
				BugsNotebookOpen[f, ops]
			}
		]


(* ::Subsubsection::Closed:: *)
(*BugsNotebookCell*)



Options[BugsNotebookCell]=
	{
		"Title"->Automatic,
		"Description"->Automatic,
		"Timestamp"->Automatic,
		"Examples"->None,
		"Resolved"->False,
		"Keywords"->{},
		"Package"->None
		};
BugsNotebookCell[tag_String, ops:OptionsPattern[]]:=
	Module[
		{
			title,
			desc,
			stamp,
			kw,
			ex,
			res,
			pack
			},
		title=
			Replace[OptionValue["Title"],
				{
					Except[_String?(StringLength[#]>0&)]->"<<Title>>"
					}
				];
		pack=
			Replace[OptionValue["Package"],
				{
					Except[_String?(StringLength[#]>0&)]->"<<Package>>"
					}
				];
		kw=
			Replace[OptionValue["Keywords"],
				{
					s_String?(StringLength[#]>0&):>
						StringTrim@StringSplit[s, ","],
					Except[{__String}]->{"keyword1", "keyword2"}
					}
				];
		stamp=
			Replace[OptionValue["Timestamp"], 
				{
					d_DateObject:>DateString[d],
					Except[_String?(StringLength[#]>0&)]->DateString[],
					s_String:>
						Replace[Quiet@DateObject[s], 
							{
								d_DateObject:>DateString[d],
								_->s
								}
							]
					}
				];
		desc=
			Replace[OptionValue["Description"],
				{
					Except[_String?(StringLength[#]>0&)]->"<<Description>>"
					}
				];
		ex=
			Replace[OptionValue["Examples"],
				Except[_List]:>{"<<Example>>"}
				];
		res=
			TrueQ@OptionValue["Resolved"];
		Cell[
			CellGroupData@
				{
					Cell[
						TextData@
							{
								title,
								Cell[BoxData@ToBoxes@Spacer[25],
									Deployed->True,
									Deletable->False
									],
								Cell[
									BoxData@
										TogglerBox[
											Dynamic[
												CurrentValue[
													EvaluationCell[],
													{TaggingRules, "Bugs", tag, "Resolved"},
													res
													]
												],
											{
												True->"\[CheckmarkedBox]",
												False->"\[EmptySquare]"
												},
											"\[CheckedBox]"
											],
									"BugResolved",
									CellTags->{"Bug", tag, "Resolved"},
									Deployed->True,
									Deletable->False
									]
								},
						"Section", "BugTitle", 
						CellTags->{"Bug", tag, "Title"}
						],
					Cell[stamp, "Message", "Text", "BugTimestamp", 
						CellTags->{"Bug", tag, "Timestamp"}
						],
					Cell[
						pack, "Text", "BugPackage",
						CellTags->{"Bug", tag, "Package"}
						],
					Cell[
						TextData@Riffle[kw, ", "], "Text", "BugKeywords", 
						CellTags->{"Bug", tag, "Keywords"}
						],
					Cell[desc, "Text", "BugDescription",
						CellTags->{"Bug", tag, "Description"}
						],
					Cell[
						CellGroupData@Flatten@{
							Cell["Examples", "Subsection", "BugExamples",
								CellTags->{"Bug", tag, "Examples"}
								],
							Replace[
								ex,
								{
									s_String:>
										Cell[s, "Text"],
									e:Except[_String]:>
										Cell[BoxData@ToBoxes[e], "Output"]
									},
								1
								]
							}
						]
					}
				]
			]


(* ::Subsubsection::Closed:: *)
(*BugsNotebookAdd*)



Options[BugsNotebookAdd]=
	Options[BugsNotebookCell];
BugsNotebookAdd[nb_NotebookObject, tag_String, ops:OptionsPattern[]]:=
	FrontEndExecute@
		{
			FrontEnd`SelectionMove[nb, After, Notebook];
			FrontEnd`NotebookWrite[nb,
				BugsNotebookCell[tag ,ops]
				]
			};


(* ::Subsubsection::Closed:: *)
(*BugsNotebookLocate*)



BugsNotebookLocate//Clear
Options[BugsNotebookLocate]=
	{
		"ReturnCellObject"->False,
		"HighlightGroup"->True
		};
BugsNotebookLocate[nb_NotebookObject, tag_, ops:OptionsPattern[]]:=
	With[{cells=Cells[nb, CellTags->{tag}]},
		Replace[
			Pick[
				cells,
				#=={"Bug", tag, "Title"}&/@
					CurrentValue[cells, CellTags]
				],
			{
				{c_, ___}:>
					(
						If[TrueQ@OptionValue["HighlightGroup"],
							SelectionMove[c, All, CellGroup]
							];
						If[TrueQ@OptionValue["ReturnCellObject"],
							c
							]
						),
				_->$Failed
				}
			]
		]


(* ::Subsection:: *)
(*Stylesheet Stuff*)



(* ::Subsubsection::Closed:: *)
(*BugsNotebookAddDialog*)



bugDialogEntry//Clear


bugDialogEntry[sym_, key_, ops:OptionsPattern[]]:=
	Sequence[
		Row@{Spacer[10], Style[key, "Subsection"]},
		Row@{
			Spacer[25],
			InputField[
				Dynamic[sym[key]],
				String,
				FieldHint->ToLowerCase@key,
				BoxID->ToLowerCase@key,
				ops
				]
			}
		];
bugDialogEntry~SetAttributes~HoldFirst


BugsNotebookAddDataDialog//Clear
BugsNotebookAddDataDialog[ops:OptionsPattern[]]:=
	DialogInput[
		{bugData=<|"Tag"->"", "Title"->"", "Package"->"", "Keywords"->""|>},
		Pane[
			EventHandler[
				Column@{
					Style["Bug info:", "Section"],
					Spacer[{5, 10}],
					bugDialogEntry[bugData, "Tag",
						FieldSize->30],
					bugDialogEntry[bugData, "Title",
						FieldSize->30],
					bugDialogEntry[bugData, "Package",
						FieldSize->30],
					bugDialogEntry[bugData, "Keywords",
						FieldSize->30
						],
					bugDialogEntry[bugData, "Description",
						FieldSize->{30, 4}
						]
					},
				{
					"ReturnKeyDown":>
						DialogReturn@
							If[StringLength@bugData["Tag"]>0, bugData, $Canceled],
					"EscapeKeyDown":>
						DialogReturn[$Canceled]
					}
				],
			{300, 350},
			Alignment->Center
			],
		ops,
		NotebookDynamicExpression:>
			Refresh[
				FrontEnd`MoveCursorToInputField[EvaluationNotebook[], "tag"],
				None
				]
		]


(* ::Subsubsection::Closed:: *)
(*BugsNotebookSearchBar*)



BugsNotebookSearchBar//Clear
BugsNotebookSearchBar[ops:OptionsPattern[]]:=
	Row@{
		Panel[
			EventHandler[
				InputField[
					Dynamic@
						CurrentValue[EvaluationNotebook[], 
							{TaggingRules, "Bugs", "SearchInterface", "SearchText"},
							""
							],
					String,
					ops,
					Appearance->"Frameless"
					],
				{
					"ReturnKeyDown":>
						(
							Replace[
								BugsNotebookLocate[
									EvaluationNotebook[],
									CurrentValue[EvaluationNotebook[], 
										{TaggingRules, "Bugs", "SearchInterface", "SearchText"}
										]
									],
								$Failed:>Beep[]
								];
							CurrentValue[EvaluationNotebook[], 
								{TaggingRules, "Bugs", "SearchInterface", "SearchText"}
								]=""
							)
					}
				],
			FrameMargins->{{5, 5}, {5, 5}},
			Appearance->
				{
					"Hover"->
						FrontEnd`FileName[{"BugTracker"}, "SearchBackground-Hover.png"]
					}
			],
	Spacer[5],
	Button[
		"",
		(
			Replace[
				BugsNotebookLocate[
					EvaluationNotebook[],
					CurrentValue[EvaluationNotebook[], 
						{TaggingRules, "Bugs", "SearchInterface", "SearchText"}
						]
					],
				$Failed:>Beep[]
				];
			CurrentValue[EvaluationNotebook[], 
				{TaggingRules, "Bugs", "SearchInterface", "SearchText"}
				]=""
			),
		Appearance->
			{
				"Default"->FrontEnd`FileName[{"BugTracker"}, "Search-Default.png"],
				"Hover"->FrontEnd`FileName[{"BugTracker"}, "Search-Hover.png"],
				"Pressed"->FrontEnd`FileName[{"BugTracker"}, "Search-Pressed.png"]
				},
		ImageSize->{16, 16}
		]
	}


(* ::Subsection:: *)
(*Bugs Objects*)



(* ::Subsubsection::Closed:: *)
(*BugsCellToBug*)



(* ::Subsubsubsection::Closed:: *)
(*bugsCellParseTitle*)



bugsCellParseTitle[t_]:=
	Replace[t,
		{TextData[s___]:>Flatten[{s}][[1]]}
		]


(* ::Subsubsubsection::Closed:: *)
(*bugsCellParsePackage*)



bugsCellParsePackage[p_]:=p


(* ::Subsubsubsection::Closed:: *)
(*bugsCellParseTimestamp*)



bugsCellParseTimestamp[d_]:=DateObject[d]


(* ::Subsubsubsection::Closed:: *)
(*bugsCellParseKeywords*)



bugsCellParseKeywords[kw_]:=
	StringTrim@StringSplit[kw, ","]


(* ::Subsubsubsection::Closed:: *)
(*bugsCellParseDescription*)



bugsCellParseDescription[e_]:=e;


(* ::Subsubsubsection::Closed:: *)
(*bugsCellParseExamples*)



bugsCellParseExamples[e_]:=
	Replace[NotebookTools`FlattenCellGroups[e],
		{
			Cell[c_, "Text", ___]:>c
			}
		]


(* ::Subsubsubsection::Closed:: *)
(*BugsCellToBug*)



BugsCellToBug[c_Cell, ops:OptionsPattern[]]:=
	With[{tag=FirstCase[c, (CellTags->{"Bug", t_, _}):>t, None, Infinity]},
		BugObject@
			<|
				"Tag"->tag,
				"Title"->
					FirstCase[c, 
						Cell[t_, ___, CellTags->{"Bug", tag, "Title"}, ___]:>
							bugsCellParseTitle[t],
						None,
						Infinity
						],
				"Resolved"->
					FirstCase[c, 
						Cell[___, TaggingRules->{___, "Bugs"->tr_, ___}, ___]:>
							Lookup[
								Lookup[tr, tag, <||>],
								"Resolved",
								False
								],
						False,
						Infinity
						],
				"Timestamp"->
					FirstCase[c, 
						Cell[ts_, ___, CellTags->{"Bug", tag, "Timestamp"}, ___]:>
							bugsCellParseTimestamp[ts],
						None,
						Infinity
						],
				"Package"->
					FirstCase[c, 
						Cell[p_, ___, CellTags->{"Bug", tag, "Package"}, ___]:>
							bugsCellParsePackage@p,
						None,
						Infinity
						],
				"Keywords"->
						FirstCase[c, 
							Cell[kw_, ___, CellTags->{"Bug", tag, "Keywords"}, ___]:>
								bugsCellParseKeywords@kw,
							None,
							Infinity
							],
				"Description"->
					FirstCase[c, 
						Cell[d_, ___, CellTags->{"Bug", tag, "Description"}, ___]:>
							bugsCellParseDescription@d,
						None,
						Infinity
						],
				"Examples"->
					FirstCase[c, 
						Cell[e_, ___, CellTags->{"Bug", tag, "Examples"}, ___]:>
							bugsCellParseExamples@e,
						None,
						Infinity
						]
				|>
		]


(* ::Subsubsection::Closed:: *)
(*BugsNotebookToBugs*)



BugsNotebookToBugs[nb_Notebook]:=
	BugsCellToBug/@
		Cases[nb, 
			Cell[CellGroupData[{Cell[__, "BugTitle", ___], ___}, ___], ___],
			Infinity
			];
BugsNotebookToBugs[nb_NotebookObject]:=
	Replace[NotebookRead[nb],
		{
			c:Cell[CellGroupData[{Cell[__, "BugTitle", ___], ___}, ___], ___]:>
				BugsCellToBug/@{c},
			c:{Cell[CellGroupData[{Cell[__, "BugTitle", ___], ___}, ___], ___]..}:>
				BugsCellToBug/@{c},
			_:>
				BugsNotebookToBugs@NotebookGet[nb]
			}
		]


(* ::Subsubsection::Closed:: *)
(*BugsToDataset*)



BugsToDataset[b:{__BugObject}]:=
	Dataset@
		Map[First, b]


(* ::Subsubsection::Closed:: *)
(*BugObject*)



MakeBoxes[b:BugObject[a_Association], form_]:=
	BoxForm`ArrangeSummaryBox[
		"BugObject",
		b,
		Pane[
			RawBoxes@
				DynamicBox[
					FEPrivate`ImportImage@
						FrontEnd`FileName[{"BugTracker"}, "BeetleIcon.png"]
					],
			{28, 28},
			ImageSizeAction->"ShrinkToFit"
			],
		{
			BoxForm`MakeSummaryItem[{"Tag: ", Lookup[a, "Tag", "Untagged"]}, form]
			},
		KeyValueMap[
			BoxForm`MakeSummaryItem[{Row@{#, ": "}, #2}, form]&,
			KeyDrop[a, "Tag"]
			],
		form
		]


End[];


