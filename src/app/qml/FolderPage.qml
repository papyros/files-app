/*
* Files app - File manager for Papyros
* Copyright (C) 2015 Michael Spencer <sonrisesoftware@gmail.com>
*               2015 Ricardo Vieira <ricardo.vieira@tecnico.ulisboa.pt>
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*/
import QtQuick 2.2
import QtQuick.Layouts 1.2
import Material 0.1
import Material.ListItems 0.1 as ListItem
import "components"

Page {
    id: folderPage

    title: folderModel.title
    actionBar.elevation: 0

    backAction: Action {
        iconName: "navigation/arrow_back"
        name: qsTr("Back")
        enabled: folderModel.canGoBack
        shortcut: StandardKey.Back
        visible: true

        onTriggered: folderModel.goBack()
    }

    actions: [
        Action {
            iconName: "action/search"
            name: qsTr("Search")
            shortcut: StandardKey.Find
            onTriggered: searchCard.state = (searchCard.state == "active" ? "inactive" : "active")
        },
        // TODO enable when we have other views - ricardomv
        //Action {
        //    iconName: "action/list"
        //    name: qsTr("List mode")
        //},
        Action {
            iconName: "file/create_new_folder"
            name: qsTr("New folder")
            shortcut: StandardKey.New
            onTriggered: confirmNewFolder.show()
        },
        Action {
            iconName: "content/content_paste"
            name: qsTr("Paste")
            shortcut: StandardKey.Paste
            enabled: folderModel.model.clipboardUrlsCounter
            visible: enabled
            onTriggered: folderModel.model.paste()
        },
        Action {
            visible: false
            shortcut: "Alt+Up"
            onTriggered: folderModel.model.cdUp()
        },
        Action {
            visible: false
            shortcut: "Ctrl+H"
            onTriggered: folderModel.model.toggleShowHiddenFiles();
        },
        //Action {
        //    iconName: "action/open_in_new"
        //    name: qsTr("Open in Terminal")
        //},
        Action {
            iconName: "action/settings"
            name: qsTr("Settings")
            onTriggered: settings.show()
        }
    ]

    rightSidebar: InfoSidebar {
        id: infoSidebar
    }

    FolderListView {
        anchors {
            left: placesSidebar.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }

        model: folderModel.model
        delegate: FileListItem {}

        Snackbar {
            id: snackbar
            Connections {
                target: folderModel.model
                onError: snackbar.open(errorTitle)
            }
        }

        Card {
            id: searchCard
            width:  Units.dp(300)
            height: Units.dp(50)
            anchors.top: parent.bottom
            anchors.margins: Units.dp(8)
            anchors.horizontalCenter: parent.horizontalCenter

            states: [
                State {
                    name: "active"
                    AnchorChanges {
                        target: searchCard
                        anchors.top: undefined
                        anchors.bottom: parent.bottom
                    }

                    PropertyChanges {
                        target: searchField
                        focus: true
                    }

                    PropertyChanges {
                        target: folderModel.model
                        nameFilters: "*"
                        filterDirectories: true

                    }
                },
                State {
                    name: "inactive"
                    AnchorChanges {
                        target: searchCard
                        anchors.top: parent.bottom
                        anchors.bottom: undefined
                    }

                    PropertyChanges {
                        target: searchField
                        text: ""
                        focus: false

                    }

                    PropertyChanges {
                        target: folderModel.model
                        nameFilters: "*"
                        filterDirectories: false
                    }
                }
            ]

            transitions: [
                Transition {
                    to: "active"
                    AnchorAnimation {
                        targets: [searchCard]
                        duration: 150
                        easing: Easing.OutQuad
                    }
                },
                Transition {
                    to: "inactive"
                    AnchorAnimation {
                        targets: [searchCard]
                        duration: 250
                        easing: Easing.InQuad
                    }
                }
            ]


            RowLayout {
                anchors.fill: parent
                anchors.margins: Units.dp(8)
                spacing: Units.dp(16)
                Icon {
                    name: "action/search"
                }
                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: qsTr("Search")
                    onAccepted: {
                        folderModel.model.nameFilters = [ "*" + text + "*" ]
                    }
                    Keys.onPressed: {
                        if (event.key == Qt.Key_Escape) {
                            searchCard.state = "inactive"
                        }
                    }
                }

                IconButton {
                    iconName: "navigation/close"
                    onClicked: searchCard.state = "inactive"
                }
            }
        }
    }

    PlacesSidebar {
        id: placesSidebar
    }

    Dialog {
        id: confirmNewFolder
        title: qsTr("Create new folder:")

        TextField {
            id: nameField
            width: parent.width
            placeholderText: qsTr("New Folder")
        }

        onAccepted: folderModel.model.mkdir(nameField.text ||
                                            nameField.placeholderText)
        onRejected: nameField.text = ""
    }

    Keys.onEscapePressed: selectionManager.clear()
}
