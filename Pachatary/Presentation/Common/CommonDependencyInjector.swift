import Swift

class CommonDependencyInjector {

    static func selectLocationPresenter(_ view: SelectLocationView,
                                        _ initialLatitude: Double?,
                                        _ initialLongitude: Double?) -> SelectLocationPresenter {
        return SelectLocationPresenter(view, initialLatitude, initialLongitude)
    }
}
