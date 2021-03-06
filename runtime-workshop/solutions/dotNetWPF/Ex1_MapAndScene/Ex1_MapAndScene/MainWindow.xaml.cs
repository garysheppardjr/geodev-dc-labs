﻿using Esri.ArcGISRuntime.Mapping;
using Esri.ArcGISRuntime.Geometry;
using Esri.ArcGISRuntime.Symbology;
using Esri.ArcGISRuntime.Data;
using Esri.ArcGISRuntime.Tasks.NetworkAnalysis;
using Esri.ArcGISRuntime.Portal;
using Esri.ArcGISRuntime.Security;

using System;
using System.Diagnostics;
using System.Linq;
using System.Windows;

namespace Ex1_MapAndScene
{
    public partial class MainWindow : Window
    {
        private Map myMap = null;
        private static string ELEVATION_IMAGE_SERVICE =
        "http://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer";
        private Scene myScene = null;
        private bool threeD = false;

        public MainWindow()
        {
            InitializeComponent();

            //Exercise 1 create the UI, setup the control references, and execute initalization
            Initialize();
        }
        private void Initialize()
        {
            //Exercise 1: Create new Map with basemap and initial location
            myMap = new Map(Basemap.CreateStreetsVector());

            //Exercise 1: Assign the map to the MapView
            mapView.Map = myMap;
        }

        private void ViewButton_Click(object sender, RoutedEventArgs e)
        {
            //Change button to 2D or 3D when button is clicked
            ViewButton.Content = FindResource(ViewButton.Content == FindResource("3D") ? "2D" : "3D");
            if (ViewButton.Content == FindResource("2D"))
            {
                if (myScene == null)
                {
                    //Create a new scene
                    myScene = new Scene(Basemap.CreateImageryWithLabels());
                    sceneView.Scene = myScene;
                    
                    // create an elevation source
                    var elevationSource = new ArcGISTiledElevationSource(new System.Uri(ELEVATION_IMAGE_SERVICE));
                    
                    // create a surface and add the elevation surface
                    var sceneSurface = new Surface();
                    sceneSurface.ElevationSources.Add(elevationSource);
                    
                    // apply the surface to the scene
                    sceneView.Scene.BaseSurface = sceneSurface;
                }
                //Once the scene has been created hide the mapView and show the sceneView
                mapView.Visibility = Visibility.Hidden;
                sceneView.Visibility = Visibility.Visible;
                threeD = true;
            }
            else
            {
                sceneView.Visibility = Visibility.Hidden;
                mapView.Visibility = Visibility.Visible;
                threeD = false;
            }
        }
    }
}

