cmake_minimum_required(VERSION 3.3.0)

project(plib VERSION 1.8.5)

set(CMAKE_DEBUG_POSTFIX d)

# Sources & Headers
set(fnt_SOURCES
    src/fnt/fnt.cxx
    src/fnt/fntBitmap.cxx
    src/fnt/fntTXF.cxx)

set(fnt_HEADERS
    src/fnt/fnt.h
    src/fnt/fntLocal.h)

set(js_SOURCES
    src/js/js.cxx
    src/js/jsBSD.cxx
    src/js/jsLinux.cxx
    src/js/jsMacOS.cxx
    src/js/jsMacOSX.cxx
    src/js/jsNone.cxx
    src/js/jsWindows.cxx)

set(js_HEADERS
    src/js/js.h)

set(net_SOURCES
    src/net/netBuffer.cxx
    src/net/netChannel.cxx
    src/net/netChat.cxx
    src/net/netMessage.cxx
    src/net/netMonitor.cxx
    src/net/netSocket.cxx)

set(net_HEADERS
    src/net/netBuffer.h
    src/net/netChannel.h
    src/net/netChat.h
    src/net/netMessage.h
    src/net/netMonitor.h
    src/net/netSocket.h)

set(psl_SOURCES
    src/psl/psl.cxx
    src/psl/pslCodeGen.cxx
    src/psl/pslCompiler.cxx
    src/psl/pslContext.cxx
    src/psl/pslDump.cxx
    src/psl/pslError.cxx
    src/psl/pslExpression.cxx
    src/psl/pslFileIO.cxx
    src/psl/pslProgram.cxx
    src/psl/pslSymbols.cxx
    src/psl/pslToken.cxx)

set(psl_HEADERS
    src/psl/psl.h
    src/psl/pslCompiler.h
    src/psl/pslContext.h
    src/psl/pslFileIO.h
    src/psl/pslLocal.h
    src/psl/pslOpcodes.h
    src/psl/pslSymbol.h)

set(puAux_SOURCES
    src/puAux/puAux.cxx
    src/puAux/puAuxBiSlider.cxx
    src/puAux/puAuxBiSliderWithEnds.cxx
    src/puAux/puAuxChooser.cxx
    src/puAux/puAuxComboBox.cxx
    src/puAux/puAuxCompass.cxx
    src/puAux/puAuxFileSelector.cxx
    src/puAux/puAuxLargeInput.cxx
    src/puAux/puAuxList.cxx
    src/puAux/puAuxScrollBar.cxx
    src/puAux/puAuxSelectBox.cxx
    src/puAux/puAuxSliderWithInput.cxx
    src/puAux/puAuxSpinBox.cxx
    src/puAux/puAuxTriSlider.cxx
    src/puAux/puAuxVerticalMenu.cxx)

set(puAux_HEADERS
    src/puAux/puAux.h
    src/puAux/puAuxLocal.h)

set(pui_SOURCES
    src/pui/pu.cxx
    src/pui/puArrowButton.cxx
    src/pui/puBox.cxx
    src/pui/puButton.cxx
    src/pui/puButtonBox.cxx
    src/pui/puDial.cxx
    src/pui/puDialogBox.cxx
    src/pui/puFont.cxx
    src/pui/puFrame.cxx
    src/pui/puGroup.cxx
    src/pui/puInput.cxx
    src/pui/puInputBase.cxx
    src/pui/puInterface.cxx
    src/pui/puListBox.cxx
    src/pui/puMenuBar.cxx
    src/pui/puObject.cxx
    src/pui/puOneShot.cxx
    src/pui/puPopup.cxx
    src/pui/puPopupMenu.cxx
    src/pui/puRange.cxx
    src/pui/puSlider.cxx
    src/pui/puText.cxx
    src/pui/puValue.cxx)

set(pui_HEADERS
    src/pui/pu.h
    src/pui/puFLTK.h
    src/pui/puGLUT.h
    src/pui/puLocal.h
    src/pui/puNative.h
    src/pui/puPW.h
    src/pui/puSDL.h)

set(pw_SOURCES
    src/pw/pwWindows.cxx)

set(pw_HEADERS
    src/pw/pw.h)

set(sg_SOURCES
    src/sg/sg.cxx
    src/sg/sgd.cxx
    src/sg/sgdIsect.cxx
    src/sg/sgIsect.cxx
    src/sg/sgPerlinNoise.cxx)

set(sg_HEADERS
    src/sg/sg.h)

set(sl_SOURCES
    src/sl/slDSP.cxx
    src/sl/slEnvelope.cxx
    src/sl/slMODdacio.cxx
    src/sl/slMODfile.cxx
    src/sl/slMODinst.cxx
    src/sl/slMODnote.cxx
    src/sl/slMODPlayer.cxx
    src/sl/slPlayer.cxx
    src/sl/slSample.cxx
    src/sl/slSamplePlayer.cxx
    src/sl/slScheduler.cxx
    src/sl/smMixer.cxx)

set(sl_HEADERS
    src/sl/sl.h
    src/sl/slMODfile.h
    src/sl/slMODPrivate.h
    src/sl/slPortability.h
    src/sl/sm.h)

set(ssg_SOURCES
    src/ssg/ssg.cxx
    src/ssg/ssgAnimation.cxx
    src/ssg/ssgAnimTransform.cxx
    src/ssg/ssgAxisTransform.cxx
    src/ssg/ssgBase.cxx
    src/ssg/ssgBaseTransform.cxx
    src/ssg/ssgBranch.cxx
    src/ssg/ssgContext.cxx
    src/ssg/ssgCutout.cxx
    src/ssg/ssgDList.cxx
    src/ssg/ssgEntity.cxx
    src/ssg/ssgInvisible.cxx
    src/ssg/ssgIO.cxx
    src/ssg/ssgIsect.cxx
    src/ssg/ssgLeaf.cxx
    src/ssg/ssgList.cxx
    src/ssg/ssgLoad.cxx
    src/ssg/ssgLoad3ds.cxx
    src/ssg/ssgLoadAC.cxx
    src/ssg/ssgLoadASC.cxx
    src/ssg/ssgLoadASE.cxx
    src/ssg/ssgLoadATG.cxx
    src/ssg/ssgLoadBMP.cxx
    src/ssg/ssgLoadDOF.cxx
    src/ssg/ssgLoadDXF.cxx
    src/ssg/ssgLoaderWriterStuff.cxx
    src/ssg/ssgLoadFLT.cxx
    src/ssg/ssgLoadIV.cxx
    src/ssg/ssgLoadM.cxx
    src/ssg/ssgLoadMD2.cxx
    src/ssg/ssgLoadMDL.cxx
    src/ssg/ssgLoadMDL_BGLTexture.cxx
    src/ssg/ssgLoadOBJ.cxx
    src/ssg/ssgLoadOFF.cxx
    src/ssg/ssgLoadPCX.cxx
    src/ssg/ssgLoadPNG.cxx
    src/ssg/ssgLoadSGI.cxx
    src/ssg/ssgLoadSSG.cxx
    src/ssg/ssgLoadStrip.cxx
    src/ssg/ssgLoadTexture.cxx
    src/ssg/ssgLoadTGA.cxx
    src/ssg/ssgLoadTRI.cxx
    src/ssg/ssgLoadVRML1.cxx
    src/ssg/ssgLoadX.cxx
    src/ssg/ssgLoadXPlaneObj.cxx
    src/ssg/ssgOptimiser.cxx
    src/ssg/ssgParser.cxx
    src/ssg/ssgRangeSelector.cxx
    src/ssg/ssgRoot.cxx
    src/ssg/ssgSave3ds.cxx
    src/ssg/ssgSaveAC.cxx
    src/ssg/ssgSaveASC.cxx
    src/ssg/ssgSaveASE.cxx
    src/ssg/ssgSaveATG.cxx
    src/ssg/ssgSaveDXF.cxx
    src/ssg/ssgSaveFLT.cxx
    src/ssg/ssgSaveIV.cxx
    src/ssg/ssgSaveM.cxx
    src/ssg/ssgSaveOBJ.cxx
    src/ssg/ssgSaveOFF.cxx
    src/ssg/ssgSaveQHI.cxx
    src/ssg/ssgSaveTRI.cxx
    src/ssg/ssgSaveVRML1.cxx
    src/ssg/ssgSaveX.cxx
    src/ssg/ssgSelector.cxx
    src/ssg/ssgSimpleList.cxx
    src/ssg/ssgSimpleState.cxx
    src/ssg/ssgState.cxx
    src/ssg/ssgStateSelector.cxx
    src/ssg/ssgStateTables.cxx
    src/ssg/ssgStatistics.cxx
    src/ssg/ssgStats.cxx
    src/ssg/ssgTexTrans.cxx
    src/ssg/ssgTexture.cxx
    src/ssg/ssgTransform.cxx
    src/ssg/ssgTween.cxx
    src/ssg/ssgTweenController.cxx
    src/ssg/ssgVertSplitter.cxx
    src/ssg/ssgVTable.cxx
    src/ssg/ssgVtxArray.cxx
    src/ssg/ssgVtxTable.cxx)

set(ssg_HEADERS
    src/ssg/ssg.h
    src/ssg/ssg3ds.h
    src/ssg/ssgKeyFlier.h
    src/ssg/ssgLoaderWriterStuff.h
    src/ssg/ssgLoadMDL.h
    src/ssg/ssgLoadVRML.h
    src/ssg/ssgLocal.h
    src/ssg/ssgMSFSPalette.h
    src/ssg/ssgParser.h
    src/ssg/ssgVertSplitter.h)

set(ssgAux_SOURCES
    src/ssgAux/ssgAux.cxx
    src/ssgAux/ssgaBillboards.cxx
    src/ssgAux/ssgaCelestialBody.cxx
    src/ssgAux/ssgaCloudLayer.cxx
    src/ssgAux/ssgaFire.cxx
    src/ssgAux/ssgaLensFlare.cxx
    src/ssgAux/ssgaLensFlareTexture.cxx
    src/ssgAux/ssgaParticleSystem.cxx
    src/ssgAux/ssgaPatch.cxx
    src/ssgAux/ssgaScreenDump.cxx
    src/ssgAux/ssgaShapes.cxx
    src/ssgAux/ssgaSky.cxx
    src/ssgAux/ssgaSkyDome.cxx
    src/ssgAux/ssgaSphere.cxx
    src/ssgAux/ssgaStars.cxx
    src/ssgAux/ssgaTeapot.cxx
    src/ssgAux/ssgaWaveSystem.cxx)

set(ssgAux_HEADERS
    src/ssgAux/ssgAux.h
    src/ssgAux/ssgaBillboards.h
    src/ssgAux/ssgaFire.h
    src/ssgAux/ssgaLensFlare.h
    src/ssgAux/ssgaParticleSystem.h
    src/ssgAux/ssgaScreenDump.h
    src/ssgAux/ssgaShapes.h
    src/ssgAux/ssgaSky.h
    src/ssgAux/ssgaSphere.h
    src/ssgAux/ssgaWaveSystem.h)

set(ul_SOURCES
    src/util/ul.cxx
    src/util/ulClock.cxx
    src/util/ulError.cxx
    src/util/ulLinkedList.cxx
    src/util/ulList.cxx
    src/util/ulRTTI.cxx)

set(ul_HEADERS
    src/util/ul.h
    src/util/ulLocal.h
    src/util/ulRTTI.h)

# Create and configure the targets
add_library(plib_fnt STATIC ${fnt_SOURCES} ${fnt_HEADERS})
target_include_directories(plib_fnt PRIVATE src/sg src/util)

add_library(plib_js STATIC ${js_SOURCES} ${js_HEADERS})
target_include_directories(plib_js PRIVATE src/util)

add_library(plib_net STATIC ${net_SOURCES} ${net_HEADERS})
target_include_directories(plib_net PRIVATE src/util)

add_library(plib_psl STATIC ${psl_SOURCES} ${psl_HEADERS})
target_include_directories(plib_psl PRIVATE src/util)

add_library(plib_puAux STATIC ${puAux_SOURCES} ${puAux_HEADERS})
target_include_directories(plib_puAux PRIVATE
    src/fnt
    src/pui
    src/sg
    src/util
)

add_library(plib_pui STATIC ${pui_SOURCES} ${pui_HEADERS})
target_include_directories(plib_pui PRIVATE src/fnt src/sg src/util)

add_library(plib_pw STATIC ${pw_SOURCES} ${pw_HEADERS})
target_include_directories(plib_pw PRIVATE src/util)

add_library(plib_sg STATIC ${sg_SOURCES} ${sg_HEADERS})
target_include_directories(plib_sg PRIVATE src/util)

add_library(plib_sl STATIC ${sl_SOURCES} ${sl_HEADERS})
target_include_directories(plib_sl PRIVATE src/util)

add_library(plib_ssg STATIC ${ssg_SOURCES} ${ssg_HEADERS})
target_include_directories(plib_ssg PRIVATE src/sg src/util)

add_library(plib_ssgAux STATIC ${ssgAux_SOURCES} ${ssgAux_HEADERS})
target_include_directories(plib_ssgAux PRIVATE src/sg src/ssg src/util)

add_library(plib_ul STATIC ${ul_SOURCES} ${ul_HEADERS})

# Install
install(
    TARGETS plib_fnt plib_js plib_net plib_psl plib_puAux plib_pui plib_pw plib_sg plib_sl plib_ssg plib_ssgAux plib_ul
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

install(
    FILES ${fnt_HEADERS}
          ${js_HEADERS}
          ${net_HEADERS}
          ${psl_HEADERS}
          ${puAux_HEADERS}
          ${pui_HEADERS}
          ${pw_HEADERS}
          ${sg_HEADERS}
          ${sl_HEADERS}
          ${ssg_HEADERS}
          ${ssgAux_HEADERS}
          ${ul_HEADERS}
    DESTINATION include/plib
)
