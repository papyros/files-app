/*
* Files app - File manager for Papyros
* Copyright (C) 2015 Michael Spencer <sonrisesoftware@gmail.com>
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
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import Material 0.1
import Material.Extras 0.1
import Material.ListItems 0.1 as ListItem

PageSidebar {
    id: infoSidebar

    actionBar.backgroundColor: Palette.colors.blue["600"]
    width: Units.dp(320)

    showing: selectedFile != undefined

    actionBar.extendedContent: Item {
        height: Units.dp(72)
        width: parent.width

        ColumnLayout {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width

            spacing: Units.dp(3)

            Label {
                Layout.fillWidth: true

                elide: Text.ElideRight

                text: selectedFile != undefined ? selectedFile.fileName : ""
                style: "subheading"
                color: Theme.dark.textColor
            }

            Label {
                Layout.fillWidth: true

                elide: Text.ElideRight
                text: selectedFile != undefined
                      ? qsTr("Edited ") + DateUtils.friendlyTime(selectedFile.modifiedDate) : ""
                color: Theme.dark.subTextColor
            }
        }
    }

    actions: [
        Action {
            iconName: "social/share"
        },

        Action {
            iconName: "action/delete"
            onTriggered: confirmAction("", qsTr("Are you sure you want to delete \"%1\"?")
                    .arg(selectedFile.fileName), qsTr("Delete")).done(function() {
                folderModel.model.removeIndex(selectedFile.index)
            })
        },

        Action {
            visible: getArchiveType(selectedFile.fileName) != ""
            iconName: "files/folder"
            name: qsTr("Extract")
            onTriggered: extractArchive(selectedFile.filePath, selectedFile.fileName, selectedFile.archiveType)
        }
    ]

    Column {
        anchors.fill: parent

        Image {
            fillMode: Image.PreserveAspectFit

            width: parent.width
            height: Math.min(width * sourceSize.height/sourceSize.width,
                             width)

            visible: selectedFile != undefined && selectedFile.mimeType.indexOf("image/") == 0

            source: visible ? selectedFile.filePath : ""
        }

        ListItem.Subheader {
            text: qsTr("Info")
        }

        Item {
            id: infoItem

            height: infoGrid.height + Units.dp(16)
            width: parent.width

            GridLayout {
                id: infoGrid

                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - Units.dp(32)

                columns: 2
                columnSpacing: Units.dp(32)
                rowSpacing: Units.dp(16)

                Label {
                    text: qsTr("Location")
                }

                Label {
                    Layout.fillWidth: true

                    text: folderModel.path
                    color: Theme.light.subTextColor
                }

                Label {
                    text: qsTr("Type")
                }

                Label {
                    Layout.fillWidth: true

                    text: {
                        if (selectedFile != undefined) {
                            var description = selectedFile.mimeTypeDescription

                            return description.substring(0, 1).toUpperCase() +
                                   description.substring(1)
                        } else {
                            return ""
                        }
                    }
                    color: Theme.light.subTextColor
                }

                Label {
                    text: selectedFile != undefined && selectedFile.isDir
                          ? qsTr("Contents") : qsTr("Size")
                }

                Label {
                    Layout.fillWidth: true

                    text: selectedFile != undefined ? selectedFile.fileSize : ""
                    color: Theme.light.subTextColor
                }
            }
        }

        ThinDivider {}
    }

    function extractArchive(filePath, fileName, archiveType) {
        console.log("Extract accepted for filePath, fileName", filePath, fileName)
        console.log("Extracting...")

        var parentDirectory = filePath.substring(0, filePath.lastIndexOf("/"))
        var fileNameWithoutExtension = fileName.substring(0, fileName.lastIndexOf(archiveType) - 1)
        var extractDirectory = parentDirectory + "/" + fileNameWithoutExtension

        // Add numbers if the directory already exist: myfile, myfile-1, myfile-2, etc.
        while (folderModel.model.existsDir(extractDirectory)) {
            var i = 0
            while ("1234567890".indexOf(extractDirectory.charAt(extractDirectory.length - i - 1)) !== -1) {
                i++
            }
            if (i === 0 || extractDirectory.charAt(extractDirectory.length - i - 1) !== "-") {
                extractDirectory += "-1"
            } else {
                extractDirectory = extractDirectory.substring(0, extractDirectory.lastIndexOf("-") + 1) + (parseInt(extractDirectory.substring(extractDirectory.length - i)) + 1)
            }
        }

        folderModel.model.mkdir(extractDirectory) // This is needed for the tar command as the given destination has to be an already existing directory

        if (archiveType === "zip") {
            archives.extractZip(filePath, extractDirectory)
        } else if (archiveType === "tar") {
            archives.extractTar(filePath, extractDirectory)
        } else if (archiveType === "tar.gz") {
            archives.extractGzipTar(filePath, extractDirectory)
        } else if (archiveType === "tar.bz2") {
            archives.extractBzipTar(filePath, extractDirectory)
        }
    }

    function getArchiveType(fileName) {
        var splitName = fileName.split(".")

        if (splitName.length <= 1) { // To sort out files simply named "zip" or "tar"
            return ""
        }

        var fileExtension = splitName[splitName.length - 1]
        if (fileExtension === "zip") {
            return "zip"
        } else if (fileExtension === "tar") {
            return "tar"
        } else if (fileExtension === "gz") {
            if (splitName.length > 2 && splitName[splitName.length - 2] === "tar") {
                return "tar.gz"
            } else {
                return ""
            }
        } else if (fileExtension === "bz2") {
            if (splitName.length > 2 && splitName[splitName.length - 2] === "tar") {
                return "tar.bz2"
            } else {
                return ""
            }
        } else {
            return ""
        }
    }
}
