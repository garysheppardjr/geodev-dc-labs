/* Copyright 2016 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1
import QtPositioning 5.3
import QtQuick.Dialogs 1.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0


//------------------------------------------------------------------------------

App {
    id: app
    width: 640
    height: 480

    property var selectedId
    property string errorMsg
    property int facilities: 0
    property double scaleFactor: System.displayScaleFactor


    Envelope {
        id: initialExtent
        xMax: -8539362.27
        yMax: 4723928.16
        xMin: -8610295.83
        yMin: 4702907.97
        spatialReference: map.spatialReference
    }
    Rectangle {
        id: titleRect
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        height: titleText.paintedHeight + titleText.anchors.margins * 2
        color: app.info.propertyValue("titleBackgroundColor", "darkblue")

        Text {
            id: titleText

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 2 * AppFramework.displayScaleFactor
            }

            text: app.info.title
            color: app.info.propertyValue("titleTextColor", "white")
            font {
                pointSize: 22
            }
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            maximumLineCount: 2
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }

    }

    Map {
        id: map

        anchors {
            left: parent.left
            right: parent.right
            top: titleRect.bottom
            bottom: parent.bottom
        }

        wrapAroundEnabled: true
        rotationByPinchingEnabled: true
        magnifierOnPressAndHoldEnabled: true
        mapPanningByMagnifierEnabled: true
        zoomByPinchingEnabled: true

        positionDisplay {
            positionSource: PositionSource {
            }
        }
        UserCredentials {
            id: oAuthCredentials
            oAuthClientInfo: OAuthClientInfo {
                clientId: "XXXXXX"
                clientSecret: "XXXXXXXX"
                oAuthMode: Enums.OAuthModeApp

            }
        }
        ArcGISTiledMapServiceLayer {
            url: app.info.propertyValue("basemapServiceUrl", "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        }

        GraphicsLayer {
                    id: startGraphics
                    renderer: SimpleRenderer {
                        SimpleMarkerSymbol {
                            style: Enums.SimpleMarkerSymbolStyleSquare
                            size: 10
                            color: "green"
                        }
                    }
        }

        onStatusChanged: {
            if (status === Enums.MapStatusReady) {
                extent = initialExtent;
                startGraphics.renderingMode = Enums.RenderingModeStatic;
                addLayer(startGraphics);

            }
        }


        Graphic {
                id: bufferGraphic
                symbol: SimpleFillSymbol {
                    color: Qt.rgba(0.0, 0, 0.5, 0.5)
                    outline:  SimpleLineSymbol {
                        color: "aqua"
                        style: Enums.SimpleLineSymbolStyleSolid
                        width: 2
                    }
                }
            }

        NorthArrow {
            anchors {
                right: parent.right
                top: parent.top
                margins: 10
            }

            visible: map.mapRotation != 0
        }

        ZoomButtons {
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: 10
            }
        }

        Column{
            id: controls
            spacing: 10
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                margins: 10
            }

            Button {
                id: bufferqueryButton
                enabled: true
                Image {
                        anchors.fill: parent
                        source: "https://raw.githubusercontent.com/garys-esri/geodev-dc-labs/master/2016-11-runtime/images/location.png"
                        fillMode: Image.Tile
                }

                checkable: true
                width: 50
                height: 50
                checked: false
                onPressedChanged: {
                    if (!checked){
                        startGraphics.removeAllGraphics();
                        metrostopsLayer.clearSelection();
                    }
                    console.log("onpressedchanged", checked)
                }


            }

            Button {
                id: drivetimeButton
                enabled: true
                Image {
                    anchors.fill: parent
                    source: "https://raw.githubusercontent.com/garys-esri/geodev-dc-labs/master/2016-11-runtime/images/car.png"
                    fillMode: Image.Tile
                }
                checkable: true
                width: 50
                height: 50
                checked: false

                onPressedChanged: {
                    if (!checked){
                        startGraphics.removeAllGraphics();
                    }

                    console.log("onpressedchanged", checked)
                }
            }
        }


        GeodatabaseFeatureServiceTable {
                id: metroLineTable
                url: "http://services.arcgis.com/lA2FZKuu26Fips7U/arcgis/rest/services/MetroLines/FeatureServer/0"
        }

        FeatureLayer{
            id: metrolineLayer
            featureTable: metroLineTable
            visible: true
        }

        GeodatabaseFeatureServiceTable {
                id: featureServiceTable
                url: "http://services.arcgis.com/lA2FZKuu26Fips7U/arcgis/rest/services/MetroStops/FeatureServer/0"
        }

        FeatureLayer {
                    id: metrostopsLayer
                    featureTable: featureServiceTable
                    visible: false
        }


        ServiceAreaTaskParameters {
                id: taskParameters
            }

            ServiceAreaTask {
                id: serviceAreaTask
                url: "http://route.arcgis.com/arcgis/rest/services/World/ServiceAreas/NAServer/ServiceArea_World"

                onSolveStatusChanged: {
                    // Add the credentials to the identity manager
                    //ArcGISRuntime.identityManager.setCredential(oAuthCredentials, "https://www.arcgis.com/sharing/rest");
                    if (solveStatus === Enums.SolveStatusCompleted) {

                        var polygons = solveResult.serviceAreaPolygons.graphics;
                        for (var index = 0; index < polygons.length; index++) {
                            var polygon = polygons[index];
                            polygonFill.color = Qt.rgba(Math.random()%255, Math.random()%255, Math.random()%255, .5);
                            serviceAreaPolygonGraphic.symbol = polygonFill; // re-randomize the color
                            var graphic = serviceAreaPolygonGraphic.clone();
                            graphic.geometry = polygon.geometry;
                            startGraphics.addGraphic(graphic);
                        }
                    } else if (solveStatus === Enums.SolveStatusErrored) {
                        errorMsg = "Solve error:" + solveError.message+ "\nPlease reset and start over.";
                        messageDialog.visible = true;
                    }
                }
            }

            NAFeaturesAsFeature {
                id: facilitiesFeatures
            }

            SimpleFillSymbol {
                id: polygonFill
            }

            Graphic {
                id: serviceAreaPolygonGraphic
            }

            SimpleLineSymbol {
                id: symbolOutline
                color: "black"
                width: 0.5
            }

            SimpleMarkerSymbol {
                id: facilitySymbol
                color: "blue"
                style: Enums.SimpleMarkerSymbolStyleSquare
                size: 10
                outline: symbolOutline
            }

            Graphic {
                id: facilityGraphic
                symbol: facilitySymbol
            }



        onMouseClicked: {
            startGraphics.removeAllGraphics();
            metrostopsLayer.clearSelection();
            var graphic = ArcGISRuntime.createObject("Graphic");
            graphic.geometry = mouse.mapPoint;

            if (bufferqueryButton.checked) {
                if (startGraphics.numberOfGraphics === 0) {
                    startGraphics.addGraphic(graphic);
                    metrostopsLayer.visible = true;

                    var bufferPolygon = graphic.geometry.buffer(10000, map.spatialReference.unit);
                    var graphic1 = bufferGraphic.clone();
                    graphic1.geometry = bufferPolygon;
                    startGraphics.addGraphic(graphic1);

                    queryParams.geometry = graphic1.geometry;
                    metrostopsLayer.selectionColor = "aqua";
                    metrostopsLayer.selectFeaturesByQuery(queryParams);

                    //Uncheck the bufferquery button
                    //bufferqueryButton.checked = false;
                }
            }
            else if (drivetimeButton.checked) {
                if (startGraphics.numberOfGraphics === 0) {
                  startGraphics.addGraphic(graphic);
                  facilitiesFeatures.setFeatures(0);
                  facilities = 0;

                  facilities++;
                  facilitiesFeatures.addFeature(graphic);

                  taskParameters.facilities = facilitiesFeatures;
                  taskParameters.defaultBreaks = [1.0, 3.0, 5.0];
                  taskParameters.outSpatialReference = map.spatialReference;
                  serviceAreaTask.credentials = oAuthCredentials;
                  serviceAreaTask.solve(taskParameters);

                  //drivetimeButton.checked = false;
                }
            }

        }

    }
    Query {
            id: queryParams
            spatialRelationship: Enums.SpatialRelationshipIntersects
            outFields: ["OBJECTID_1", "NAME"]
        }
}

//------------------------------------------------------------------------------
