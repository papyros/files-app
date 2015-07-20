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
import Material 0.1
import Material.Extras 0.1
import Material.ListItems 0.1 as ListItem

Item {
    id: folderListView

    clip: true

    View {
        id: header

        visible: listView.count > 0

        z: 1
        backgroundColor: Theme.backgroundColor
        elevation: 1
        fullWidth: true

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        height: Units.dp(48)

        RowLayout {
            anchors {
                left: parent.left
                right: parent.right
                margins: Units.dp(16)
            }

            height: parent.height - Units.dp(1)
            spacing: Units.dp(16)

            Label {
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true

                text: "Name"
                color: Theme.light.subTextColor
            }

            Label {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: Units.dp(100)

                text: "Type"
                color: Theme.light.subTextColor
            }

            Label {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: Units.dp(100)

                text: "Last modified"
                color: Theme.light.subTextColor
            }
        }
    }

    ListView {
        id: listView

        anchors {
            left: parent.left
            right: parent.right
            top: header.bottom
            bottom: parent.bottom
        }

        model: folderModel.model
        delegate: FileListItem {}
    }

    Scrollbar {
        flickableItem: listView
    }

    Label {
        anchors.centerIn: parent

        text: i18n("No files")
        color: Theme.light.hintColor
        font.pixelSize: Units.dp(25)

        visible: listView.count == 0
    }
}
