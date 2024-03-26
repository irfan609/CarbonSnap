class OnboardingContents {
  final String title;
  final String image;
  final String desc;

  OnboardingContents(
      {required this.title, required this.image, required this.desc});
}

List<OnboardingContents> contents = [
  OnboardingContents(
    title: "Monitor your emission",
    image: "assets/lottie/track.json",
    desc: "If you can't measure it, you can't manage it - Peter Drucker​",
  ),
  OnboardingContents(
    title: "People, Planet, Prosperity",
    image: "assets/lottie/community.json",
    desc: "Building a greener community, one step at a time",
  ),
  OnboardingContents(
    title: "Let's get started",
    image: "assets/lottie/greenearth.json",
    desc:
        "The greatest threat to our planet is the belief that someone else will save it - Robert Swan",
  ),
];
